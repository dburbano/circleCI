//
//  CashoutATM.swift
//  machApp
//
//  Created by Lukas Burns on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct CashoutATM {
    var amount: Int
    
    public init(amount: Int) {
        self.amount = amount
    }
}

extension CashoutATM: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "amount" {
            return "amount"
        }
        return propertyName
    }
    
    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}

