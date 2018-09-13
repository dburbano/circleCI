//
//  ImageUploadResponse.swift
//  machApp
//
//  Created by lukas burns on 5/25/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct ImageUploadResponse {
    var images: Images?
}

extension ImageUploadResponse: Unboxable {

    public init(unboxer: Unboxer) throws {
        self.images = unboxer.unbox(key: "image_urls")
    }

    public static func create(from dictionary: JSON) throws -> ImageUploadResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: ImageUploadResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
