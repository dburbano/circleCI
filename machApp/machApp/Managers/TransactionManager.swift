//
//  TransactionManager.swift
//  machApp
//
//  Created by lukas burns on 5/11/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class TransactionManager {

    static func handleTransactionReceived(transaction: Transaction) throws {
        guard transaction.belongsToUser() else { return }
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            if let receivedToUser = transaction.toUser {
                transaction.toUser = ContactManager.sharedInstance.upsertUser(receivedUser: receivedToUser)
            }
            if let receivedFromUser = transaction.fromUser {
                transaction.fromUser = ContactManager.sharedInstance.upsertUser(receivedUser: receivedFromUser)
            }
            if let receivedCreatedBy = transaction.createdBy {
                transaction.createdBy = ContactManager.sharedInstance.upsertUser(receivedUser: receivedCreatedBy)
            }
            if let destinationGroup = realm.objects(Group.self).first(where: { (group) -> Bool in
                group.identifier == transaction.groupId
            }) {
                // Group exists
                try addTransactionToExistingGroup(transaction: transaction, group: destinationGroup)
            } else {
                // Group doesn't exists
                try createNewGroup(for: transaction)
            }
    }

    static func addTransactionToExistingGroup(transaction: Transaction, group: Group) throws {
        try group.updateWithNew(transaction: transaction)
    }

    static func createNewGroup(for transaction: Transaction) throws {
        guard let groupId = transaction.groupId else { return }
        let newGroup: Group = Group(identifier: groupId)
        guard let interactedUser = transaction.getUserInteracted() else { return }
        newGroup.users.append(interactedUser)
        newGroup.transactions.append(transaction)
        newGroup.updateGroupUpdatedAt(transaction)
        let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
        try realm.write {
            realm.add(newGroup, update: true)
        }
    }

    static func handleInteractionReceived(for transactionInteractionMessage: TransactionInteractionMessage) throws {
        guard let transactionId = transactionInteractionMessage.transactionId, let transactionInteractionResponse = transactionInteractionMessage.transactionInteractionResponse else { return }
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                if let transaction = realm.object(ofType: Transaction.self, forPrimaryKey: transactionId) {
                    transaction.addTransactionInteraction(for: transactionInteractionResponse)
                    transaction.seen = false
                    if let destinationGroup = realm.objects(Group.self).first(where: { (group) -> Bool in
                        group.identifier == transaction.groupId
                    }) {
                        destinationGroup.updateGroupUpdatedAt(transaction)
                    }
                }
            }
    }
}
