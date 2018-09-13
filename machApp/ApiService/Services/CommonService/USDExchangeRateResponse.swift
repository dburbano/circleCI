//
//  USDExchangeRateResponse.swift
//  machApp
//
//  Created by Lukas Burns on 3/23/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct USDExchangeRateResponse {
    var exchangeRate: Float
}

extension USDExchangeRateResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.exchangeRate = try unboxer.unbox(key: "exchangeRate")
    }
    
    public static func create(from dictionary: JSON) throws -> USDExchangeRateResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: USDExchangeRateResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
