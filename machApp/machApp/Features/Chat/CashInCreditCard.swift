//
//  CashInCreditCard.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct CashInCreditCard {

    var inscriptionId: String?
    var amount: String?

    init(with id: String, amount: String) {
        inscriptionId = id
        self.amount = amount
    }
}

extension CashInCreditCard: WrapCustomizable {

    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "inscriptionId" {
            return "inscriptionId"
        }
        if propertyName == "amount" {
            return "amount"
        }
        return propertyName
    }

    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
