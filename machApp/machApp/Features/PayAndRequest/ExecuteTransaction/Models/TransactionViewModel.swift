//
//  TransactionViewModel.swift
//  machApp
//
//  Created by lukas burns on 3/30/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

enum TransactionType {
    case paymentSent
    case paymentReceived
    case requestSent
    case requestReceived
    case unknown
}

enum TransactionStatus {
    case pending
    case rejected
    case closed
    case cancelled
    case completed
    case unknown
}

class TransactionViewModel: ChatMessageBaseViewModel {
    let transaction: Transaction

    var toUser: UserViewModel?
    var completedAt: Date?
    var cancelledAt: Date?
    var rejectedAt: Date?
    var createdBy: UserViewModel?

    required init(transaction: Transaction) {
        self.transaction = transaction
        var fromUserViewModel: UserViewModel? = nil
        if let fromUser = transaction.fromUser {
            fromUserViewModel = UserViewModel(user: fromUser)
        }
        let createdAt = transaction.createdAt as Date?
        super.init(groupId: transaction.groupId, seen: transaction.seen, amount: transaction.amount, message: transaction.message, createdAt: createdAt, fromUser: fromUserViewModel, updatedAt: transaction.updatedAt)

        if let toUser = transaction.toUser {
            self.toUser = UserViewModel(user: toUser)
        } else { self.toUser = nil }
        if let createdByUser = transaction.createdBy {
            self.createdBy = UserViewModel(user: createdByUser)
        } else { self.createdBy = nil }

        self.completedAt = transaction.completedAt as Date?
        self.cancelledAt = transaction.cancelledAt as Date?
        self.rejectedAt = transaction.rejectedAt as Date?
    }

    func isPayment() -> Bool {
        return fromUser?.user.identifier == createdBy?.user.identifier
    }

    func isSent() -> Bool {
        let machId = AccountManager.sharedInstance.getMachId()
        return createdBy?.user.machId == machId
    }

    func isClosed() -> Bool {
        return completedAt != nil || cancelledAt != nil || rejectedAt != nil
    }

    func isRejected() -> Bool {
        return rejectedAt != nil
    }

    func isCancelled() -> Bool {
        return cancelledAt != nil
    }

    func isCompleted() -> Bool {
        return completedAt != nil
    }

    func isPending() -> Bool {
        return completedAt == nil && cancelledAt == nil && rejectedAt == nil
    }

    func wasTransactionOriginatedByProximity() -> Bool {
        guard let originatedBy = transaction.metadata?.originatedBy else {
            return false
        }
        return originatedBy == "bluetooth"
    }

    func getTransactionType() -> TransactionType {
        if self.isPayment() && self.isSent() {
            return TransactionType.paymentSent
        } else if self.isPayment() && !self.isSent() {
            return TransactionType.paymentReceived
        } else if !self.isPayment() && !self.isSent() {
            return TransactionType.requestReceived
        } else if !self.isPayment() && self.isSent() {
            return TransactionType.requestSent
        } else {
            return TransactionType.unknown
        }
    }

    func getTransactionStatus() -> TransactionStatus {
        if isCompleted() {
            return TransactionStatus.completed
        } else if isCancelled() {
            return TransactionStatus.cancelled
        } else if isRejected() {
            return TransactionStatus.rejected
        } else if isPending() {
            return TransactionStatus.pending
        } else if isClosed() {
            return TransactionStatus.closed
        } else {
            return TransactionStatus.unknown
        }
    }

    func getLastInteraction() -> InteractionViewModel? {
        if let interaction = self.transaction.getLastInteraction() {
            return InteractionViewModel(interaction: interaction)
        }
        return nil
    }

    func getLastTransactionInteraction() -> TransactionInteraction? {
        return self.transaction.getLastTransactionInteraction()
    }
}
