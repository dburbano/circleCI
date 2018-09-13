//
//  PhoneNumberValidationResponse.swift
//  machApp
//
//  Created by lukas burns on 3/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct PhoneNumberRegistrationResponse {
    var verificationId: String
    var expiration: Int
}

extension PhoneNumberRegistrationResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.verificationId = try unboxer.unbox(key: "verification_id")
        self.expiration = try unboxer.unbox(key: "expires_in")
    }

    public static func create(from dictionary: JSON) throws -> PhoneNumberRegistrationResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: PhoneNumberRegistrationResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}

public struct PhoneNumberRegistrationChallengeResponse {
    var verificationId: String
    var expiration: Int
    var phoneNumber: String
}

extension PhoneNumberRegistrationChallengeResponse: Unboxable {
    
    public init(unboxer: Unboxer) throws {
        self.verificationId = try unboxer.unbox(key: "verification_id")
        self.expiration = try unboxer.unbox(key: "expires_in")
        self.phoneNumber = try unboxer.unbox(key: "phone_number") 
    }
    
    public static func create(from dictionary: JSON) throws -> PhoneNumberRegistrationChallengeResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: PhoneNumberRegistrationChallengeResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
