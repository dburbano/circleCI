//
//  TEFVerificationResponse.swift
//  machApp
//
//  Created by Lukas Burns on 12/21/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct TEFVerificationResponse {
    var tefVerificationId: String
    var bankId: String?
    var bankAccount: String?
    var status: String
}

extension TEFVerificationResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.tefVerificationId = try unboxer.unbox(key: "tefVerificationId")
        self.bankId = unboxer.unbox(key: "bankId")
        self.bankAccount = unboxer.unbox(key: "bankAccount")
        self.status = try unboxer.unbox(key: "tefVerificationStatus")
    }
    
    public static func create(from dictionary: JSON) throws -> TEFVerificationResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: TEFVerificationResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
