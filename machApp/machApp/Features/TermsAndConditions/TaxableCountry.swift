//
//  TaxableCountry.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 8/4/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct TaxableCountry {

    var country: String
    var dni: String
    var countryCode: String

    init(country: String, dni: String, countryCode: String) {
        self.country = country
        self.dni = dni
        self.countryCode = countryCode
    }
}

extension TaxableCountry: WrapCustomizable {
    
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "dni" {
            return "document_id"
        }
        if propertyName == "countryCode" {
            return "country_code"
        }
        if propertyName == "country" {
            return nil
        }
        return propertyName
    }
    
    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
