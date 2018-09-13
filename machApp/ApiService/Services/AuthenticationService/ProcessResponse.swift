//
//  ProcessResponse.swift
//  machApp
//
//  Created by Lukas Burns on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

//
//  ProcessResponse.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct ProcessResponse {
    var id: String
    var completed: Bool
    var completedSteps: Int
    var totalSteps: Int
    var goal: String
}

extension ProcessResponse: Unboxable {
    
    public init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "id")
        completed = try unboxer.unbox(key: "completed")
        completedSteps = try unboxer.unbox(keyPath: "steps.completed")
        totalSteps = try unboxer.unbox(keyPath: "steps.total")
        goal = try unboxer.unbox(keyPath:"goal")
    }
    
    public static func create(from dictionary: JSON) throws -> ProcessResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: ProcessResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
