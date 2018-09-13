//
//  TransactionInteractionMessage.swift
//  machApp
//
//  Created by lukas burns on 11/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

struct TransactionInteractionMessage {

    var transactionId: String?
    var transactionInteractionResponse: TransactionInteractionResponse?

}
extension TransactionInteractionMessage: Unboxable {
    init(unboxer: Unboxer) throws {
        self.transactionId = unboxer.unbox(key: "movementId")
        self.transactionInteractionResponse = unboxer.unbox(key: "interaction")
    }

    public static func create(from dictionary: JSON) throws -> TransactionInteractionMessage {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: TransactionInteractionMessage = try unbox(dictionary: dictionaryObject)
        return response
    }
}
