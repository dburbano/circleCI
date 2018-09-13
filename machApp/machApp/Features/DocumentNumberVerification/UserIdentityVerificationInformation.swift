//
//  UserRegistrationViewModel.swift
//  machApp
//
//  Created by lukas burns on 2/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct UserIdentityVerificationInformation {

    var rut: String
    var serialNumber: String

    public init(rut: String, serialNumber: String) {
        self.rut = rut
        self.serialNumber = serialNumber
    }
}

extension UserIdentityVerificationInformation: WrapCustomizable {

    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "rut" {
            return "rut"
        }
        if propertyName == "serialNumber" {
            return "id_serial_number"
        }
        return propertyName
    }

    public func toParams() throws -> [String : Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
