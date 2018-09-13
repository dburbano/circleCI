//
//  OnlineSignalResponse.swift
//  machApp
//
//  Created by lukas burns on 4/12/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct OnlineSignalResponse {
    var channel: String
    var subscribeKey: String
    var cipherKey: String?
    var authKey: String?
}

extension OnlineSignalResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.channel = try unboxer.unbox(key: "channel")
        self.subscribeKey = try unboxer.unbox(key: "subscribe_key")
        self.cipherKey = unboxer.unbox(key: "cipher_key")
        self.authKey = unboxer.unbox(key: "auth_key")
    }

    public static func create(from dictionary: JSON) throws -> OnlineSignalResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: OnlineSignalResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
