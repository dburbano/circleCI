//
//  SignUpDateResponse.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/10/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct SignupDateResponse {
    var signupDate: Date

    init(date: Date) {
        signupDate = date
    }
}

extension SignupDateResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        signupDate = try Date().dateFromISOString(isoDateString: unboxer.unbox(key: "created_at")) ?? Date()
    }

    public static func create(from dictionary: JSON) throws -> SignupDateResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: SignupDateResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
