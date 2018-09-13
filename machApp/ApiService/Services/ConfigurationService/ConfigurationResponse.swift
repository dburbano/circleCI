//
//  ConfigurationResponse.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/12/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct ConfigurationResponse {
    var maxContactsInvitation: Int
    var machProfile: MachProfileResponse
    var onboarding: MachProfileOnboardingResponse
    var maxContactsForGroup: Int
}

extension ConfigurationResponse: Unboxable {

    public init(unboxer: Unboxer) throws {
        self.maxContactsInvitation = try unboxer.unbox(key: "max_contacts_to_trigger_invitation")
        self.machProfile = try unboxer.unbox(key: "mach_team_profile")
        self.onboarding = try unboxer.unbox(key: "onboarding")
        self.maxContactsForGroup = unboxer.unbox(keyPath: "payment_requests.max_contacts_for_group") ?? 15
    }

    public static func create(from dictionary: JSON) throws -> ConfigurationResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: ConfigurationResponse = try unbox(dictionary: dictionaryObject)
        return response
    }

}
