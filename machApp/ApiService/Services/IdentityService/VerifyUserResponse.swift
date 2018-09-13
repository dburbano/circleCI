//
//  VerifyUserResponse.swift
//  machApp
//
//  Created by lukas burns on 4/12/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct VerifyUserResponse {
    var isAccountLocked: Bool?
    var userProfile: UserProfileResponse?
    var machId: String?
}

extension VerifyUserResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        //self.machId = try unboxer.unbox(key: "mach_id")
        self.isAccountLocked = unboxer.unbox(key: "is_account_locked")
        self.userProfile = unboxer.unbox(key: "account_user")
        self.machId = unboxer.unbox(key: "mach_id")
    }

    public static func create(from dictionary: JSON) throws -> VerifyUserResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: VerifyUserResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}
