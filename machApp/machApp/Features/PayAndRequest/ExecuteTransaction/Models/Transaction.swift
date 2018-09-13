//
//  Transaction.swift
//  machApp
//
//  Created by lukas burns on 4/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift
import Unbox
import SwiftyJSON

class Transaction: Object, Unboxable {

    @objc dynamic var identifier: String?
    @objc dynamic var fromUser: User?
    @objc dynamic var toUser: User?
    @objc dynamic var createdBy: User?
    @objc dynamic var amount: Int = 0
    @objc dynamic var message: String?
    @objc dynamic var groupId: String?
    @objc dynamic var completedAt: Date?
    @objc dynamic var createdAt: Date?
    @objc dynamic var cancelledAt: Date?
    @objc dynamic var rejectedAt: Date?
    @objc dynamic var seen: Bool = false
    @objc dynamic var updatedAt: Date?
    @objc dynamic var metadata: TransactionMetadata?
    let transactionInteractions = List<TransactionInteraction>()

    convenience required init(unboxer: Unboxer) throws {
        self.init()
        self.identifier = unboxer.unbox(key: "id")
        self.fromUser = unboxer.unbox(key: "fromUser")
        self.toUser = unboxer.unbox(key: "toUser")
        self.message = unboxer.unbox(key: "message")
        self.createdBy = unboxer.unbox(key: "createdByUser")
        self.metadata = unboxer.unbox(key: "metadata")
        self.groupId = unboxer.unbox(key: "groupId")
        self.amount = try unboxer.unbox(key: "amount")
        self.completedAt = unboxer.unbox(key: "completedAt", formatter: Date().getISODateFormatter())
        self.createdAt = unboxer.unbox(key: "createdAt", formatter: Date().getISODateFormatter())
        self.rejectedAt = unboxer.unbox(key: "rejectedAt", formatter: Date().getISODateFormatter())
        self.cancelledAt = unboxer.unbox(key: "cancelledAt", formatter: Date().getISODateFormatter())
        self.updatedAt = unboxer.unbox(key: "updatedAt", formatter: Date().getISODateFormatter())
        do {
            let transactionInteractionResponse: TransactionInteractionResponse = try unboxer.unbox(key: "interaction")
            self.addTransactionInteraction(for: transactionInteractionResponse)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
        setUpdatedAt()
    }

    convenience init(identifier: String?, fromUser: User?, toUser: User?, createdBy: User?, message: String?, groupId: String?, completedAt: Date?, createdAt: Date?, cancelledAt: Date?, rejectedAt: Date?, updatedAt: Date?) {
        self.init()
        self.identifier = identifier
        self.fromUser = fromUser
        self.toUser = toUser
        self.createdBy = createdBy
        self.message = message
        self.groupId = groupId
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.cancelledAt = cancelledAt
        self.rejectedAt = rejectedAt
        self.updatedAt = updatedAt
    }

    override static func primaryKey() -> String? {
        return "identifier"
    }

    func getUserInteracted() -> User? {
        let selfMachId = AccountManager.sharedInstance.getMachId()
        return toUser?.machId != selfMachId ? toUser : fromUser
    }

    func setUpdatedAt() {
        if let createdAt = createdAt, let completedAt = completedAt {
            setUpdatedAtToBiggerDate(date1: createdAt, date2: completedAt)
        } else if let createdAt = createdAt, let rejectedAt = rejectedAt {
            setUpdatedAtToBiggerDate(date1: createdAt, date2: rejectedAt)
        } else if let createdAt = createdAt, let cancelledAt = cancelledAt {
            setUpdatedAtToBiggerDate(date1: createdAt, date2: cancelledAt)
        } else {
            self.updatedAt = createdAt
        }
    }

    func setUpdatedAtToBiggerDate(date1: Date, date2: Date) {
        if date1 < date2 {
            self.updatedAt = date2
        }
    }

    func belongsToUser() -> Bool {
        let selfMachId = AccountManager.sharedInstance.getMachId()
        return toUser?.machId == selfMachId || fromUser?.machId == selfMachId
    }

    func markAsSeen() {
        do {
            try Realm(configuration: RealmManager.getRealmConfiguration()).write {
                self.seen = true
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func markAsNotSeen() {
        do {
            try Realm(configuration: RealmManager.getRealmConfiguration()).write {
                self.seen = false
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func addTransactionInteraction(for transactionInteractionResponse:  TransactionInteractionResponse) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            guard let interaction = realm.object(ofType: Interaction.self, forPrimaryKey: transactionInteractionResponse.interactionId),
                let date = transactionInteractionResponse.date else { return }
            let transactionInteraction = TransactionInteraction(interaction: interaction, date: date, reactedBy: transactionInteractionResponse.reactedBy, availableAt: transactionInteractionResponse.availableAt, triesRemaining: transactionInteractionResponse.triesRemaining)
            self.transactionInteractions.append(transactionInteraction)
            self.updatedAt = transactionInteraction.date
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func addTransactionInteraction(transactionInteraction: TransactionInteraction) {
        self.transactionInteractions.append(transactionInteraction)
        self.updatedAt = transactionInteraction.date
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            if let destinationGroup = realm.objects(Group.self).first(where: { (group) -> Bool in
                group.identifier == self.groupId
            }) {
                destinationGroup.updatedAt = updatedAt
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func getLastInteraction() -> Interaction? {
        if let lastTransactionInteraction = self.getLastTransactionInteraction() {
            return lastTransactionInteraction.interaction
        }
        return nil
    }

    func getLastTransactionInteraction() -> TransactionInteraction? {
        let orderedTransactionInteractions = Array(transactionInteractions).sorted(by: { (transaction1, transaction2) -> Bool in
            if let date1 = transaction1.date, let date2 = transaction2.date {
                return date1.compare(date2) == .orderedDescending
            }
            return false
        })
        return orderedTransactionInteractions.first
    }

}

extension Transaction {

    public static func create(from dictionary: JSON) throws -> Transaction {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: Transaction = try unbox(dictionary: dictionaryObject)
        return response
    }

    public static func createArray(from dictionaryArray: JSON) throws -> [Transaction] {
        guard let arrayObject = dictionaryArray.arrayObject as? [UnboxableDictionary], let response: [Transaction] = try? unbox(dictionaries: arrayObject) else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        return response
    }
}
