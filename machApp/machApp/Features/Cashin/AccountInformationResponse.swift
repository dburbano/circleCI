//
//  AccountInformationResponse.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/10/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct AccountInformationResponse {
    var fullName: String
    var rut: String
    var bank: String
    var accountNumber: String
    var accountType: String
}

extension AccountInformationResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.fullName = try unboxer.unbox(key: "full_name")
        self.rut = try unboxer.unbox(key: "rut")
        self.bank = try unboxer.unbox(key: "bank")
        self.accountNumber = try unboxer.unbox(key: "account_number")
        self.accountType = try unboxer.unbox(key: "account_type")
    }

    public static func create(from dictionary: JSON) throws -> AccountInformationResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: AccountInformationResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
