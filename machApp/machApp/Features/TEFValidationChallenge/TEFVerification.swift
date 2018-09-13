//
//  TEFVerification.swift
//  machApp
//
//  Created by Lukas Burns on 12/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct TEFVerification {
    var bankId: String
    var bankAccount: String
    
    init(bankId: String, bankAccount: String) {
        self.bankId = bankId
        self.bankAccount = bankAccount
    }
}

extension TEFVerification: WrapCustomizable {
    
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "bankAccount" {
            return "bankAccount"
        }
        if propertyName == "bankId" {
            return "bankId"
        }
        return propertyName
    }
    
    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
