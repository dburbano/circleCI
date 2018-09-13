//
//  MachEvent.swift
//  machApp
//
//  Created by Lukas Burns on 4/13/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import RealmSwift
import Unbox
import SwiftyJSON

enum Event: String {
    case prepaidCardCreated = "prepaid-card-created"
    case tefVerificationDepositError = "identity-tef-verification-deposit-failure-invalid-input"
    case accountCreated = "account-created"
    case authenticationEmailVerified = "authentication-email-verified"
    case prepaidCardRemoved = "prepaid-card-deleted"
}

public struct MachEvent {
    var event: Event?
}

extension MachEvent: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.event = Event(rawValue: try unboxer.unbox(key: "event"))
    }
    
    public static func create(from dictionary: JSON) throws -> MachEvent {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: MachEvent = try unbox(dictionary: dictionaryObject)
        return response
    }
}
