//
//  MachActionParameter.swift
//  machApp
//
//  Created by lukas burns on 8/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

import Foundation
import RealmSwift
import Unbox
import SwiftyJSON

public struct MachParameter {
    var key: String?
    var value: String?
}

extension MachParameter: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.key = unboxer.unbox(key: Constants.MachParameter.key)
        self.value = unboxer.unbox(key: Constants.MachParameter.value)
    }
    
    public static func create(from dictionary: JSON) throws -> MachParameter {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: MachParameter = try unbox(dictionary: dictionaryObject)
        return response
    }
}

protocol MachParameterProtocol {
    var params: [MachParameter] { get set }
}

extension MachParameterProtocol {
    func getParameter(with key: String) -> MachParameter? {
        for param in params {
            if param.key == key {
                return param
            }
        }
        return nil
    }
}
