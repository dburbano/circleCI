//
//  MachProfileResponse.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/12/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct MachProfileResponse {
    var machID: String
    var name: String
    var imageUrls: MachProfileThumbnailsResponse
}

extension MachProfileResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.machID = try unboxer.unbox(key: "machId")
        self.name = try unboxer.unbox(key: "firstName")
        self.imageUrls = try unboxer.unbox(key: "imageUrls")
    }

    public static func create(from dictionary: JSON) throws -> MachProfileResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: MachProfileResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
