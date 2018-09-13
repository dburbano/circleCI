//
//  Payment.swift
//  machApp
//
//  Created by lukas burns on 3/30/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

struct Payment {
    var toMachId: String?
    var toPhoneNumber: String
    var message: String
    var amount: Int
    var metadata: TransactionMetadata?

    public init(toMachId: String?, toPhoneNumber: String, message: String, amount: Int) {
        self.toMachId = toMachId
        self.message = message
        self.amount = amount
        self.toPhoneNumber = toPhoneNumber
    }
}

extension Payment: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "toMachId" {
            return "to_mach_id"
        }
        if propertyName == "toPhoneNumber" {
            return "to_phone_number"
        }
        if propertyName == "metadata" {
            return "metadata"
        }
        return propertyName
    }

    public func toParams() throws -> [String : Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
