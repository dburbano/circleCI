//
//  PubNubManager.swift
//  machApp
//
//  Created by lukas burns on 4/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import PubNub
import SwiftyJSON

enum MessageType: String {
    case movement = "movement"
    case machMessage = "mach-team-message"
    case profile = "profile"
    case machAction = "action"
    case interaction = "interaction"
    case machEvent = "event"
}

class PubNubManager: NSObject, PNObjectEventListener {

    var client: PubNub!
    var notificationManagerDelegate: NotificationManagerDelegate?

    override init() {
        super.init()
    }

    init(subscribeKey: String, channel: String, cipherKey: String?, authKey: String?) {
        super.init()
        let configuration = PNConfiguration(publishKey: "", subscribeKey: subscribeKey)
        if let cipherKey = cipherKey {
            configuration.cipherKey = cipherKey
        }
        if let authKey = authKey {
            configuration.authKey = authKey
        }
        configuration.TLSEnabled = true
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
        self.client.subscribeToChannels([channel], withPresence: false)
    }

    func stop() {
        client?.unsubscribeFromAll()
    }

    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        if message.data.channel != message.data.subscription {

        } else {

        }
        if let messageData = message.data.message, let dataType = message.data.userMetadata?["type"] as? String, let messageType = MessageType(rawValue: dataType) {
            let json = JSON.init(messageData)
            switch messageType {
                //Yo creo q acá debería llegar el mensaje q el correo fue validado
            case .movement :
                do {
                    let transaction: Transaction = try Transaction.create(from: json)
                    try TransactionManager.handleTransactionReceived(transaction: transaction)
                    self.acknowledgeMessageReceived(message: message)
                    NotificationCenter.default.post(name: .DidReceiveTransaction, object: nil)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    print("Error: \(error)")
                }
            case .profile:
                do {
                    let userProfileResponse = try UserProfileResponse.create(from: json)
                    let user: User = User(userProfileResponse: userProfileResponse)
                    _ = ContactManager.sharedInstance.upsertUser(receivedUser: user)
                    self.acknowledgeMessageReceived(message: message)
                    NotificationCenter.default.post(name: .ProfileDidUpdate, object: nil)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    print("Error: \(error)")
                }
            case .machMessage:
                do {
                    let machMessage: MachMessage = try MachMessage.create(from: json)
                    MachMessageManager.handleMachMessageReceived(machMessage: machMessage)
                    self.acknowledgeMessageReceived(message: message)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    print("Error: \(error)")
                }
            case .machAction:
                do {
                    let action: MachAction = try MachAction.create(from: json)
                    if let command = action.command {
                        switch command {
                        case .logout:
                            if action.params.first?.key == "sessionId", action.params.first?.value == AlamofireNetworkLayer.sharedInstance.getSessionId() {
                                NotificationCenter.default.post(name: .UserLoggedOut, object: nil)
                            }
                        }
                    }
                    self.acknowledgeMessageReceived(message: message)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    print("Error: \(error)")
                }
            case .machEvent:
                do {
                    let machEvent: MachEvent = try MachEvent.create(from: json)
                    if let event = machEvent.event {
                        switch event {
                        case .prepaidCardCreated:
                            if let prepaidCardResponse = try? PrepaidCardResponse.create(from: json["body"]["prepaidCard"]) {
                                let prepaidCard = PrepaidCard.init(prepaidCardResponse: prepaidCardResponse)
                                NotificationCenter.default.post(name: .PrepaidCardCreated, object: self, userInfo: ["prepaidCard": prepaidCard])
                            }
                        case .prepaidCardRemoved:
                            // remove local card saved
                            NotificationCenter.default.post(name: .PrepaidCardRemoved, object: self)
                        case .tefVerificationDepositError:
                            NotificationCenter.default.post(name: .TEFVerificationDepositError, object: self)
                        case .accountCreated:
                            NotificationCenter.default.post(name: .AccountCreated, object: self)
                        case .authenticationEmailVerified:
                            NotificationCenter.default.post(name: .EmailChallengeCompleted, object: self)
                        }
                    }
                    self.acknowledgeMessageReceived(message: message)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    print("Error: \(error)")
                }
            case .interaction:
                do {
                    let transactionInteractionMessage = try TransactionInteractionMessage.create(from: json)
                    try TransactionManager.handleInteractionReceived(for: transactionInteractionMessage)
                    self.acknowledgeMessageReceived(message: message)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    print("Error: \(error)")
                }
            }

        }

    }

    func acknowledgeMessageReceived(message: PNMessageResult) {
        if let messageMetaData = message.data.userMetadata?["messageId"] as? String {
            let messageAcknowledgement = MessageAcknowledgement(messageId: messageMetaData)
            do {
                try AlamofireNetworkLayer.sharedInstance.request(SignalService.acknowledge(parameters: messageAcknowledgement.toParams()), onSuccess: { (_) in
                    print("se acknowledgio un mensaje con meta data \(messageMetaData)")
                }, onError: { (error) in
                    print(error.detailedError())
                })
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                print ("oh hubo un error en llamar al servico de ack")
            }
        }
    }

    func notifySubscriptionSuccesfull() {
        AlamofireNetworkLayer.sharedInstance.request(SignalService.subscribed, onSuccess: { (_) in
            print("we should start receiving houston!")
        }) { (networkError) in
            print(networkError.detailedError())
        }
    }

    // Handle subscription status change.
    func client(_ client: PubNub, didReceive status: PNStatus) {
        if status.operation == .subscribeOperation {
            // Check whether received information about successful subscription or restore.
            if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
                if let subscribeStatus: PNSubscribeStatus = status as? PNSubscribeStatus {
                    if subscribeStatus.category == .PNConnectedCategory {
                        // This is expected for a subscribe, this means there is no error or issue whatsoever.
                        notifySubscriptionSuccesfull()
                        self.notificationManagerDelegate?.notificationConnectionSucceeded()
                    } else {
                        /*
                         This usually occurs if subscribe temporarily fails but reconnects. This means there was
                         an error but there is no longer any issue.
                         */
                    }
                }
            } else if status.category == .PNUnexpectedDisconnectCategory {
                /*
                 This is usually an issue with the internet connection, this is an error, handle
                 appropriately retry will be called automatically.
                 */
            }
                // Looks like some kind of issues happened while client tried to subscribe or disconnected from
                // network.
            else {
                if let errorStatus: PNErrorStatus = status as? PNErrorStatus {
                    if errorStatus.category == .PNAccessDeniedCategory {
                        /*
                         This means that PAM does not allow this client to subscribe to this channel and channel group
                         configuration. This is another explicit error.
                         */
                        print("PAM Error")
                        self.notificationManagerDelegate?.notificationConnectionFailed()
                    } else {
                        /*
                         More errors can be directly specified by creating explicit cases for other error categories
                         of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,
                         `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                         or `PNNetworkIssuesCategory`
                         */
                    }
                }
            }
        } else if status.operation == .unsubscribeOperation {
            if status.category == .PNDisconnectedCategory {
                /*
                 This is the expected category for an unsubscribe. This means there was no error in
                 unsubscribing from everything.
                 */
            }
        } else if status.operation == .heartbeatOperation {
            /*
             Heartbeat operations can in fact have errors, so it is important to check first for an error.
             For more information on how to configure heartbeat notifications through the status
             PNObjectEventListener callback, consult http://www.pubnub.com/docs/ios-objective-c/api-reference#configuration_basic_usage
             */
            if !status.isError {
                /* Heartbeat operation was successful. */
            } else { /* There was an error with the heartbeat operation, handle here. */ }
        }
    }
}
