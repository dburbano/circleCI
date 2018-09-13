//
//  BalanceResponse.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct BalanceResponse {
    var balance: Float
    var lastRetrievedDate: Date
    
    init(balance: Float) {
        self.balance = balance
        self.lastRetrievedDate = Date()
    }
}

extension BalanceResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.balance = try unboxer.unbox(key: "balance")
        do {
            self.lastRetrievedDate = try Date().dateFromISOString(isoDateString: unboxer.unbox(key: "timestamp")) ?? Date()
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            self.lastRetrievedDate = Date()
        }
    }
    
    public static func create(from dictionary: JSON) throws -> BalanceResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: BalanceResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
