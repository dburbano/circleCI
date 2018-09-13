//
//  NotificationManager.swift
//  machApp
//
//  Created by lukas burns on 4/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol NotificationManagerDelegate: class {

    func notificationConnectionFailed()

    func notificationConnectionSucceeded()
}

class NotificationManager: NotificationManagerDelegate {

    static let sharedInstance: NotificationManager = NotificationManager()
    var pubNubManager: PubNubManager?
    var retryIterator: Double = 0

    func startListeningForMessages() {
        AlamofireNetworkLayer.sharedInstance.request(SignalService.online, onSuccess: { (networkResponse) in
            do {
                // swiftlint:disable:next force_unwrapping
                let onlineSignalResponse = try OnlineSignalResponse.create(from: networkResponse.body!)
                self.pubNubManager = PubNubManager(subscribeKey: onlineSignalResponse.subscribeKey, channel: onlineSignalResponse.channel, cipherKey: onlineSignalResponse.cipherKey, authKey: onlineSignalResponse.authKey)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
            }
        }) { (networkError) in
            networkError.printDescription()
        }
    }

    func notificationConnectionFailed() {
        let delayTime = (pow(2.0, retryIterator) * 2000.0)
        Thread.runOnMainQueue(delayTime) {
            self.startListeningForMessages()
            self.retryIterator += 1
        }
    }

    func notificationConnectionSucceeded() {
        self.retryIterator = 0
    }
    
    func stop() {
        self.pubNubManager?.stop()
    }
}
