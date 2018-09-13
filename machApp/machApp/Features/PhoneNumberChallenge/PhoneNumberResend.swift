//
//  PhoneNumberResend.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct PhoneNumberResend {
    var phoneNumber: String
    var verificationID: String

    public init(phoneNumber: String, verificationID: String) {
        self.phoneNumber = phoneNumber
        self.verificationID = verificationID
    }
}

extension PhoneNumberResend: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "phoneNumber" {
            return "phone"
        }
        if propertyName == "verificationID" {
            return "verification_id"
        }
        return propertyName
    }

    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
