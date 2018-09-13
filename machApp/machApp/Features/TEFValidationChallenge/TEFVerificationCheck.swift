//
//  TefVerificationCheck.swift
//  machApp
//
//  Created by Lukas Burns on 12/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct TEFVerificationCheck {
    var tefVerificationId: String
    var amount: Int
    
    init(tefVerificationId: String, amount: Int) {
        self.tefVerificationId = tefVerificationId
        self.amount = amount
    }
}

extension TEFVerificationCheck: WrapCustomizable {
    
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "tefVerificationId" {
            return "tefVerificationId"
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
