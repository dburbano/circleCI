//
//  Request.swift
//  machApp
//
//  Created by lukas burns on 5/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

struct RequestPayment {
    var fromMachId: String?
    var fromPhoneNumber: String
    var message: String
    var amount: Int
    var metadata: TransactionMetadata?

    public init(fromMachId: String?, fromPhoneNumber: String, message: String, amount: Int, metadata: TransactionMetadata? = nil) {
        self.fromMachId = fromMachId
        self.fromPhoneNumber = fromPhoneNumber
        self.message = message
        self.amount = amount
        self.metadata = metadata
    }
}

extension RequestPayment: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "fromMachId" {
            return "fromMachId"
        }
        if propertyName == "fromPhoneNumber" {
            return "fromPhoneNumber"
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

struct RequestPayments {
    var requests: [RequestPayment] = []

    public init(requests: [RequestPayment]) {
        self.requests = requests
    }
}

extension RequestPayments: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "requests" {
            return "requests"
        }
        return propertyName
    }

    public func toParams() throws -> [String : Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
