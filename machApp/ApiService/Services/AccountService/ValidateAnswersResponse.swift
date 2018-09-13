//
//  ValidateAnswersResponse.swift
//  machApp
//
//  Created by lukas burns on 5/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct ValidateAnswersResponse {
    var success: Bool?
    var isAccountLocked: Bool?
}

extension ValidateAnswersResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.success = unboxer.unbox(key: "success")
        self.isAccountLocked = unboxer.unbox(key: "is_account_locked")
    }

    public static func create(from dictionary: JSON) throws -> ValidateAnswersResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: ValidateAnswersResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
