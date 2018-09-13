//
//  MachMessage.swift
//  machApp
//
//  Created by lukas burns on 8/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift
import Unbox
import SwiftyJSON

enum TeamMachMessageTypes: String {
    case info
    case success
    case warning
    case danger
}

class MachMessage: Object, Unboxable {

    @objc dynamic var identifier: String?
    @objc dynamic var groupId: String?
    @objc dynamic var fromUser: User?
    @objc dynamic var message: String?
    @objc dynamic var createdAt: Date?
    @objc dynamic var updatedAt: Date?
    @objc dynamic var title: String?
    @objc dynamic var amount: Int = 0
    @objc dynamic var toMachId: String?
    @objc dynamic var seen: Bool = false
    @objc dynamic var type: String = TeamMachMessageTypes.info.rawValue

    convenience required init(unboxer: Unboxer) throws {
        self.init()
        self.identifier = unboxer.unbox(key: "id")
        self.fromUser = unboxer.unbox(key: "fromUser")
        self.groupId = unboxer.unbox(key: "groupId")
        self.message = unboxer.unbox(key: "message")
        self.title = unboxer.unbox(key: "title")
        self.type = unboxer.unbox(key: "type") ?? TeamMachMessageTypes.info.rawValue
        do {
            self.amount = try unboxer.unbox(key: "amount")
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
        self.toMachId = unboxer.unbox(key: "toMachId")
        self.createdAt = unboxer.unbox(key: "createdAt", formatter: Date().getISODateFormatter())
        self.updatedAt = unboxer.unbox(key: "updatedAt", formatter: Date().getISODateFormatter())
    }

    override static func primaryKey() -> String? {
        return "identifier"
    }

    func belongsToUser() -> Bool {
        let selfMachId = AccountManager.sharedInstance.getMachId()
        if let toMachId = toMachId, toMachId == selfMachId {
            return true
        } else {
            return false
        }
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

    func getMessageType() -> TeamMachMessageTypes {
        return TeamMachMessageTypes.init(rawValue: self.type) ?? TeamMachMessageTypes.info
    }
}

extension MachMessage {
    
    public static func create(from dictionary: JSON) throws -> MachMessage {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: MachMessage = try unbox(dictionary: dictionaryObject)
        return response
    }
    
    public static func createArray(from dictionaryArray: JSON) throws -> [MachMessage] {
        guard let arrayObject = dictionaryArray.arrayObject as? [UnboxableDictionary], let response: [MachMessage] = try? unbox(dictionaries: arrayObject) else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        return response
    }
}
