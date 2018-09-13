//
//  UserTaxes.swift
//  machApp
//
//  Created by Lukas Burns on 11/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

import Foundation
import Wrap

public struct TermsAndConditionsAcceptance {
    var taxes: [TaxableCountry]
    
    public init(taxes: [TaxableCountry]) {
        self.taxes = taxes
    }
}

extension TermsAndConditionsAcceptance: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "taxes" {
            return "taxes"
        }
        return propertyName
    }
    
    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
