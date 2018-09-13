//
//  PhonenumberRegistration.swift
//  machApp
//
//  Created by lukas burns on 3/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct PhoneNumberRegistration {

    var phoneNumber: String

    public init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
}

extension PhoneNumberRegistration: WrapCustomizable {

    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "phoneNumber" {
            return "phone_number"
        }
        return propertyName
    }

    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}


public struct RequestPhoneCallTransferModel {
    var verificationID: String
}

extension RequestPhoneCallTransferModel: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "verificationID" {
            return "verification_id"
        }
        return propertyName
    }
    
    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
