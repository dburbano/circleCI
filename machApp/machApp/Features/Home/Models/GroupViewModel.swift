//
//  GroupViewModel.swift
//  machApp
//
//  Created by lukas burns on 4/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class GroupViewModel {

    let group: Group?
    var transactions: [TransactionViewModel] = []
    var machMessages: [MachMessageViewModel] = []
    var users: [UserViewModel] = []

    init(group: Group) {
        self.group = group
        updateUserViewModels()
    }

    func updateTransactionViewModels() {
        guard let group = group else { return }
        self.transactions = group.transactions.sorted(by: { (transaction1, transaction2) -> Bool in
            guard let transaction1UpdatedAt = transaction1.updatedAt,
                let transaction2UpdatedAt = transaction2.updatedAt else { return false }
            return transaction1UpdatedAt > transaction2UpdatedAt
        }).map({ (transaction) -> TransactionViewModel in
            return TransactionViewModel(transaction: transaction)
        })
    }

    func updateMachMessagesViewModels() {
        guard let group = group else { return }
        self.machMessages = group.machMessages.sorted(by: { (machMessage1, machMessage2) -> Bool in
            guard let machMessage1CreatedAt = machMessage1.createdAt, let machMessage2CreatedAt = machMessage2.createdAt else { return false }
            return machMessage1CreatedAt > machMessage2CreatedAt
        }).map({ (machMessage) -> MachMessageViewModel in
            return MachMessageViewModel(machMessage: machMessage)
        })
    }

    func updateUserViewModels() {
        guard let group = group else { return }
        self.users = group.users.map({ (user) -> UserViewModel in
            return UserViewModel(user: user)
        })
    }

    func unseenTransactions() -> Int {
        return group?.unseenChatMessages() ?? 0
    }

    func getLastChatMessage() -> ChatMessageBaseViewModel? {
        let lastTransaction = group?.getLastTransaction()
        let lastMachMessage = group?.getLastMachMessage()

        if let transaction = lastTransaction, let machMessage = lastMachMessage, let transactionUpdatedAt = transaction.updatedAt, let machMessageCreatedAt = machMessage.createdAt {
            if transactionUpdatedAt > machMessageCreatedAt {
                return TransactionViewModel(transaction: transaction)
            } else {
                return MachMessageViewModel(machMessage: machMessage)
            }
        }
        if let transaction = lastTransaction {
            return TransactionViewModel(transaction: transaction)
        } else if let machMessage = lastMachMessage {
            return MachMessageViewModel(machMessage: machMessage)
        }
        return nil
    }

    func hasPendingTransactions() -> Bool {
        let numberOfPendingTransactions = group?.pendingTransactions() ?? 0
        if numberOfPendingTransactions > 0 { return true }
        return false
    }

    func isTransactionMadeByProximityAndUserNotInContact() -> Bool {
        if let lastTransactionViewModel = self.getLastChatMessage() as? TransactionViewModel {
            if let userViewModel = self.users.first, !userViewModel.isInContacts, lastTransactionViewModel.wasTransactionOriginatedByProximity() {
                return true
            }
        }
        return false
    }

    func isInContacts() -> Bool {
        if let userViewModel = self.users.first, userViewModel.isInContacts {
            return true
        }

        return false
    }

    func markChatMessagesAsSeen() {
        do {
            try self.group?.markTransactionsAsSeen()
            try self.group?.markMachMessagesAsSeen()
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func isTransactionsPopulated() -> Bool {
        guard let group = group else {
            return false
        }
        /*
         If transactions is empty, this function return false.
         Otherwise returns true
         */
        return !group.transactions.isEmpty
    }

    func isChatMessagesPopulated() -> Bool {
        guard let group = group else {
            return false
        }
        return !group.machMessages.isEmpty
    }
}
