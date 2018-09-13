//
//  RejectRequestResponse.swift
//  machApp
//
//  Created by lukas burns on 5/4/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct RejectRequestResponse {
    var rejectedAt: Date
}

extension RejectRequestResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.rejectedAt = try Date().dateFromISOString(isoDateString: unboxer.unbox(key: "rejectedAt"))!
    }

    public static func create(from dictionary: JSON) throws -> RejectRequestResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: RejectRequestResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
