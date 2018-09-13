//
//  Group.swift
//  machApp
//
//  Created by lukas burns on 4/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class Group: Object {

    @objc dynamic var identifier: String?
    @objc dynamic var updatedAt: Date?
    let users = List<User>()
    let transactions = List<Transaction>()
    let machMessages = List<MachMessage>()

    convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
    }

    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    func updateWithNew(transaction: Transaction) throws {
        let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
        let index = transactions.index(where: { $0.identifier == transaction.identifier })
        if let index = index {
            let oldTransction = transactions[index]
            if let newTransactionUpdatedAt = transaction.updatedAt, let oldTransactionUpdatedAt = oldTransction.updatedAt, newTransactionUpdatedAt > oldTransactionUpdatedAt {
                transaction.seen = false
                try realm.write {
                    try Realm(configuration: RealmManager.getRealmConfiguration()).add(transaction, update: true)
                }
            }
        } else {
            try realm.write {
                self.transactions.append(transaction)
            }
        }
        try realm.write {
            self.updateGroupUpdatedAt(transaction)
            try Realm(configuration: RealmManager.getRealmConfiguration()).add(self, update: true)
        }
    }

    func appendOrUpdateMachMessage(_ machMessage: MachMessage) throws {
        let index = machMessages.index(where: { $0.identifier == machMessage.identifier })
        if let index = index {
            let oldMessage = machMessages[index]
            if let newMessageUpdatedAt = machMessage.updatedAt, let oldMessageUpdatedAt = oldMessage.updatedAt, newMessageUpdatedAt > oldMessageUpdatedAt {
                machMessage.seen = false
                try Realm(configuration: RealmManager.getRealmConfiguration()).add(machMessage, update: true)
            }
        } else {
            self.machMessages.append(machMessage)
        }
    }

    func updateGroupUpdatedAtWith(_ machMessage: MachMessage) {
        
        guard let machMessageUpdatedAt = machMessage.updatedAt, let updatedAt = self.updatedAt else {
            self.updatedAt = machMessage.updatedAt
            return
        }
        if machMessageUpdatedAt > updatedAt {
            self.updatedAt = machMessageUpdatedAt
        }
    }

    func updateGroupUpdatedAt(_ transaction: Transaction) {
        if let lastTransactionUpdatedAt = transaction.updatedAt,
            let groupUpdatedAt = self.updatedAt,
            groupUpdatedAt <= lastTransactionUpdatedAt {
           self.updatedAt = lastTransactionUpdatedAt
            
        } else if let lastTransaction = self.getLastTransaction(),
            let groupUpdatedAt = self.updatedAt,
            let lastTransactionUpdatedAt = lastTransaction.updatedAt,
            groupUpdatedAt < lastTransactionUpdatedAt {

           self.updatedAt = lastTransactionUpdatedAt
        } else if self.updatedAt == nil {
           self.updatedAt = transaction.updatedAt
        }
    }

    func markTransactionsAsSeen() throws {
        try Realm(configuration: RealmManager.getRealmConfiguration()).write {
            transactions.forEach({ (transaction) in
                transaction.seen = true
            })
        }
    }

    func markMachMessagesAsSeen() throws {
        try Realm(configuration: RealmManager.getRealmConfiguration()).write {
            machMessages.forEach({ (transaction) in
                transaction.seen = true
            })
        }
    }

    func getLastTransaction() -> Transaction? {
        guard let groupId = identifier else { return nil }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let transaction = realm.objects(Transaction.self).filter("groupId = %@", groupId).sorted(byKeyPath: "updatedAt", ascending: false).first
            return transaction
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            return nil
        }
    }

    func getLastMachMessage() -> MachMessage? {
        guard let groupId = identifier else { return nil }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let machMessage = realm.objects(MachMessage.self).filter("groupId = %@", groupId).sorted(byKeyPath: "createdAt", ascending: false).first
            return machMessage
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            return nil
        }
    }

    func getOldestTransaction() -> Transaction? {
        guard let groupId = identifier else { return nil }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let transaction = realm.objects(Transaction.self).filter("groupId = %@", groupId).sorted(byKeyPath: "updatedAt", ascending: true).first
            return transaction
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            return nil
        }
    }

    func unseenChatMessages() -> Int {
        guard let groupId = identifier else { return 0 }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let unseenTransactions = realm.objects(Transaction.self).filter("groupId = %@", groupId).filter("seen = %@", false).count
            let unseenMachMessages = realm.objects(MachMessage.self).filter("groupId = %@", groupId).filter("seen = %@", false).count
            return unseenTransactions + unseenMachMessages
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            return 0
        }
    }

    func pendingTransactions() -> Int {
        guard let groupId = identifier else { return 0 }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let pendingTransactions = realm.objects(Transaction.self).filter("groupId = %@ AND completedAt == nil AND rejectedAt == nil AND cancelledAt == nil", groupId).count
            return pendingTransactions
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            return 0
        }
    }
}
