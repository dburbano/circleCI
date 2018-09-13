//
//  AcceptRequestResponse.swift
//  machApp
//
//  Created by lukas burns on 5/4/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct AcceptRequestResponse {
    var completedAt: Date
}

extension AcceptRequestResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.completedAt = try Date().dateFromISOString(isoDateString: unboxer.unbox(key: "completedAt"))!
    }

    public static func create(from dictionary: JSON) throws -> AcceptRequestResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: AcceptRequestResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
