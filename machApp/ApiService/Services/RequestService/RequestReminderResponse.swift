//
//  RequestReminderResponse.swift
//  machApp
//
//  Created by lukas burns on 11/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct RequestReminderResponse {
    let remindedAt: Date
    let triesRemaining: Int
    let availableAt: Date
}

extension RequestReminderResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.remindedAt = (try Date().dateFromISOString(isoDateString: unboxer.unbox(key: "remindedAt")))!
        self.availableAt = (try Date().dateFromISOString(isoDateString: unboxer.unbox(key: "availableAt")))!
        self.triesRemaining = try unboxer.unbox(key: "triesRemaining")
    }

    public static func create(from dictionary: JSON) throws -> RequestReminderResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: RequestReminderResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
