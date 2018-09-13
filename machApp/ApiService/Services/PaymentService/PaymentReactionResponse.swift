//
//  PaymentReactionResponse.swift
//  machApp
//
//  Created by lukas burns on 11/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct PaymentReactionResponse {
    let reactedAt: Date
}

extension PaymentReactionResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.reactedAt = try Date().dateFromISOString(isoDateString: unboxer.unbox(key: "reactedAt"))!
    }

    public static func create(from dictionary: JSON) throws -> PaymentReactionResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: PaymentReactionResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
