//
//  GCMResponseModel.swift
//  machApp
//
//  Created by Lukas Burns on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

import Foundation
import Unbox
import SwiftyJSON

public struct GCMResponseModel {
    
    let iv: String
    let content: String
    let tag: String
}

extension GCMResponseModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.iv = try unboxer.unbox(key: "iv")
        self.content = try unboxer.unbox(key: "content")
        self.tag = try unboxer.unbox(key: "tag")
    }
    
    public static func create(from dictionary: JSON) throws -> GCMResponseModel {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: GCMResponseModel = try unbox(dictionary: dictionaryObject)
        return response
    }
}

