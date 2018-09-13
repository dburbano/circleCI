//
//  CreditCardResponse.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/8/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct CreditCardResponse {
    fileprivate(set) var creditCardType: String
    fileprivate(set) var id: String
    fileprivate(set) var last4Digits: String
}

extension CreditCardResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: Constants.WebPay.CreditCardResponse.id)
        self.creditCardType = try unboxer.unbox(key: Constants.WebPay.CreditCardResponse.creditCardType)
        self.last4Digits = try unboxer.unbox(key: Constants.WebPay.CreditCardResponse.last4CardDigits)
    }

    public static func create(from dictionary: JSON) throws -> CreditCardResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: CreditCardResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
