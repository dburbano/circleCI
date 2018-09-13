//
//  PrepaidCardPreviewResponse.swift
//  machApp
//
//  Created by Lukas Burns on 3/19/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

struct PrepaidCardResponse {
    var id: String
    var state: String
    var last4Pan: String?
    var holderName: String?
    var expirationMonth: String?
    var expirationYear: String?
}

extension PrepaidCardResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(keyPath: "id")
        self.state = try unboxer.unbox(keyPath: "state")
        self.last4Pan = unboxer.unbox(keyPath: "last4Pan")
        self.holderName = unboxer.unbox(keyPath: "holderName")
        self.expirationYear = unboxer.unbox(keyPath: "expirationYear")
        self.expirationMonth = unboxer.unbox(keyPath: "expirationMonth")
    }

    public static func create(from dictionary: JSON) throws -> PrepaidCardResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: PrepaidCardResponse = try unbox(dictionary: dictionaryObject)
        return response
    }

    public static func createArray(from dictionaryArray: JSON) throws -> [PrepaidCardResponse] {
        guard let arrayObject = dictionaryArray.arrayObject as? [UnboxableDictionary], let response: [PrepaidCardResponse] = try? unbox(dictionaries: arrayObject) else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        return response
    }
}

struct PrepaidCardsResponse {
    var prepaidCards: [PrepaidCardResponse]
}

extension PrepaidCardsResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.prepaidCards = try unboxer.unbox(keyPath: "prepaidCards")
    }
    
    public static func create(from dictionary: JSON) throws -> PrepaidCardsResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: PrepaidCardsResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
