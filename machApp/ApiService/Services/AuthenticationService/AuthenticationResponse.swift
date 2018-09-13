//
//  AuthenticationResponse.swift
//  machApp
//
//  Created by Lukas Burns on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct AuthenticationResponse {
    var process: ProcessResponse
    var challenge: ChallengeResponse?
}

extension AuthenticationResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        process = try unboxer.unbox(key: "process")
        challenge = unboxer.unbox(key: "challenge")
    }
    
    public static func create(from dictionary: JSON) throws -> AuthenticationResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: AuthenticationResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
