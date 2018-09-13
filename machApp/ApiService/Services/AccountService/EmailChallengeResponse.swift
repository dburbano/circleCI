//
//  VerifyEmail.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 5/21/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct EmailChallengeResponse {
    var email: String
}

extension EmailChallengeResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        email = try unboxer.unbox(key: "email")
    }
    
    public static func create(from dictionary: JSON) throws -> EmailChallengeResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: EmailChallengeResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
