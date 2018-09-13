//
//  Bank.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/19/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON


public struct WithdrawData {
    var bank: Bank
    var accountNumber: String
}

public struct Bank {
    var identifier: String
    var name: String

    public init(identifier: String, name: String) {
        self.identifier = identifier
        self.name = name
    }
}

extension Bank: Unboxable {

    public static func createArray(from dictionaryArray: JSON) throws -> [Bank] {
        guard let arrayObject = dictionaryArray.arrayObject as? [UnboxableDictionary], let response: [Bank] = try? unbox(dictionaries: arrayObject) else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        return response
    }

    public init(unboxer: Unboxer) throws {
        self.identifier = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
    }
}
