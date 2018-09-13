//
//  MachProfileOnboardingResponse.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/12/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct MachProfileOnboardingResponse {
    var maxOnboardingRequestAmount: Int
}

extension MachProfileOnboardingResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.maxOnboardingRequestAmount = try unboxer.unbox(key: "max_request_amount")
    }

    public static func create(from dictionary: JSON) throws -> MachProfileOnboardingResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: MachProfileOnboardingResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
