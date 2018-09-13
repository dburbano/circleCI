//
//  PhoneNumberValidation.swift
//  machApp
//
//  Created by lukas burns on 3/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap
import SwiftyJSON

public struct PhoneNumberValidation {

    var verificationId: String
    var verificationCode: String?

    public init(verificationId: String, verificationCode: String) {
        self.verificationId = verificationId
        self.verificationCode = verificationCode
    }
}

extension PhoneNumberValidation: WrapCustomizable {

    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "verificationId" {
            return "verification_id"
        }
        if propertyName == "verificationCode" {
            return "verification_code"
        }
        return propertyName
    }

    public func toParams() throws -> [String : Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
