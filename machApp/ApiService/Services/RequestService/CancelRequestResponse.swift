//
//  CancelRequestResponse.swift
//  machApp
//
//  Created by lukas burns on 5/4/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct CancelRequestResponse {
    var cancelledAt: Date
}

extension CancelRequestResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.cancelledAt = try Date().dateFromISOString(isoDateString: unboxer.unbox(key: "cancelledAt"))!
    }

    public static func create(from dictionary: JSON) throws -> CancelRequestResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: CancelRequestResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
