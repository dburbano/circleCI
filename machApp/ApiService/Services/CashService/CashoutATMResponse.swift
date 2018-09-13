//
//  CashoutATMResponse.swift
//  machApp
//
//  Created by Lukas Burns on 1/2/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct CashoutATMResponse {
    var id: String
    var amount: Int
    var nigCode: String
    var pin: String
    var createdAt: Date?
    var cancelledAt: Date?
    var completedAt: Date?
    var expiredAt: Date?
    var expiresAt: Date
    var currentTime: Date
    var blockedAt: Date?
}

extension CashoutATMResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(keyPath: "cash_out_atm.id")
        self.amount = try unboxer.unbox(keyPath: "cash_out_atm.amount")
        self.nigCode = try unboxer.unbox(keyPath: "cash_out_atm.nig_code")
        self.pin = try unboxer.unbox(keyPath: "cash_out_atm.pin")
        self.createdAt = unboxer.unbox(keyPath: "cash_out_atm.created_at", formatter: Date().getISODateFormatter()) ?? nil
        self.cancelledAt = unboxer.unbox(keyPath: "cash_out_atm.cancelled_at", formatter: Date().getISODateFormatter()) ?? nil
        self.completedAt = unboxer.unbox(keyPath: "cash_out_atm.completed_at", formatter: Date().getISODateFormatter()) ?? nil
        self.expiredAt = unboxer.unbox(keyPath: "cash_out_atm.expired_at", formatter: Date().getISODateFormatter()) ?? nil
        self.expiresAt = try unboxer.unbox(keyPath: "cash_out_atm.expires_at", formatter: Date().getISODateFormatter())
        self.currentTime = try unboxer.unbox(key: "current_time", formatter: Date().getISODateFormatter())
        self.blockedAt = unboxer.unbox(keyPath: "cash_out_atm.blocked_at", formatter: Date().getISODateFormatter()) ?? nil
    }
    
    public static func create(from dictionary: JSON) throws -> CashoutATMResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: CashoutATMResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
