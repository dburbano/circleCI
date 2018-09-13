//
//  UserInformationChallengeResponse.swift
//  machApp
//
//  Created by Lukas Burns on 6/6/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct UserInformationChallengeResponse {
    var firstName: String
    var lastName: String
    var rut: String
}

extension UserInformationChallengeResponse: Unboxable {
    
    public init(unboxer: Unboxer) throws {
        firstName =  try unboxer.unbox(key: "first_name")
        lastName = try unboxer.unbox(key: "last_name")
        rut = try unboxer.unbox(key: "rut")
    }
    
    public static func create(from dictionary: JSON) throws -> UserInformationChallengeResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: UserInformationChallengeResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
