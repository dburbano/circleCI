//
//  TermsAndConditionsResponse.swift
//  machApp
//
//  Created by lukas burns on 8/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct TermsAndConditionsResponse {

    let termsAndConditions: String?
}

extension TermsAndConditionsResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.termsAndConditions = unboxer.unbox(key: "terms_and_conditions")
    }

    public static func create(from dictionary: JSON) throws -> TermsAndConditionsResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: TermsAndConditionsResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
