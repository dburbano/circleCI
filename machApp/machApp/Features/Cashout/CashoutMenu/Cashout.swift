//
//  Cashout.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/19/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct Cashout {
    var bankId: String?
    var amount: Int?
    var accountNumber: String?

    public init(bankId: String, amount: Int, accountNumber: String) {
        self.bankId = bankId
        self.amount = amount
        self.accountNumber = accountNumber
    }
}

extension Cashout: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "bankId" {
            return "bank_id"
        }
        if propertyName == "amount" {
            return "amount"
        }
        if propertyName == "accountNumber" {
            return "account_number"
        }
        return propertyName
    }

    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
