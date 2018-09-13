//
//  NotificationName.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 2/28/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let ProfileDidUpdate = Notification.Name("profileUpdatedNotification")
    static let DidSaveAccount =  Notification.Name("didSaveAccountSuccesfully")
    static let DidReceiveTransaction = Notification.Name("aTransactionWasMade")
    static let PrepaidCardCreated = Notification.Name("prepaidCardCreated")
    static let PrepaidCardRemoved = Notification.Name("prepaidCardRemoved")
    static let UserLoggedOut = Notification.Name("userLoggedOut")
    static let UserBlackListed = Notification.Name("userBlackListed")
    static let TEFVerificationDepositError = Notification.Name("TEFVerificationDepositError")
    static let DidExecuteRecharge = Notification.Name("didExecuteRecharge")
    static let DidExecuteTransactionSuccesfully = Notification.Name("didExecuteTransactionSuccessfully")
    static let AccountCreated = Notification.Name("accountCreated")
    static let EmailChallengeCompleted = Notification.Name("emailChallengeCompleted")
    static let ApplicationDidEnterBackground = Notification.Name("applicationDidEnterBackground")
    static let UserDataDeleted = Notification.Name("userDataDeleted")
}
