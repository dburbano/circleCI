//
//  PrepaidCardDetailResponse.swift
//  machApp
//
//  Created by Lukas Burns on 3/19/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

struct PrepaidCardCVVResponse {
    var cvv: String
}

extension PrepaidCardCVVResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.cvv = try unboxer.unbox(keyPath: "cvv")
    }
    
    public static func create(from dictionary: JSON) throws -> PrepaidCardCVVResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: PrepaidCardCVVResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}

struct PrepaidCardPANResponse {
    var pan: String
}

extension PrepaidCardPANResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.pan = try unboxer.unbox(keyPath: "pan")
    }
    
    public static func create(from dictionary: JSON) throws -> PrepaidCardPANResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: PrepaidCardPANResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
