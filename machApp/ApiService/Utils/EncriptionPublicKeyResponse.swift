//
//  EncriptionPublicKeyResponse.swift
//  machApp
//
//  Created by lukas burns on 9/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct EncriptionPublicKeyResponse {

    let publicKey: String
}

extension EncriptionPublicKeyResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.publicKey = try unboxer.unbox(key: "public_key")
    }

    public static func create(from dictionary: JSON) throws -> EncriptionPublicKeyResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: EncriptionPublicKeyResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
