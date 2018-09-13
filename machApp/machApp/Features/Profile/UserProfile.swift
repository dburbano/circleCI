//
//  UserProfile.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/21/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct UserProfile {
    var firstName: String?
    var lastName: String?
    var birthDate: String?
    var email: String?
    var imageUrl: String?

    public init (firstName: String?, lastName: String?, birthDate: String?, email: String?, imageUrl: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.email = email
        self.imageUrl = imageUrl
    }
}

extension UserProfile {
    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
