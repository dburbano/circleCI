//
//  MachProfileThumbnailsResponse.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/12/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct MachProfileThumbnailsResponse {
    var small: String
    var medium: String
    var large: String
}

extension MachProfileThumbnailsResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.small = try unboxer.unbox(key: "small")
        self.medium = try unboxer.unbox(key: "medium")
        self.large = try unboxer.unbox(key: "large")
    }

    public static func create(from dictionary: JSON) throws -> MachProfileThumbnailsResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: MachProfileThumbnailsResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
