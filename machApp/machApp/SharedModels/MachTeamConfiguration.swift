//
//  MachTeamConfiguration.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/12/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class MachTeamConfiguration: Object {

    @objc dynamic var machId: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var smallImageURLString: String = ""
    @objc dynamic var mediumImageURLString: String = ""
    @objc dynamic var largeImageURLString: String = ""
    @objc dynamic var maxContactsToTriggerInvitation: Int = 0
    @objc dynamic var maxOnboardingRequestAmount: Int = 0
    @objc dynamic var maxContactsForGroup: Int = 15
    //This variable is used to identify whether the user's charge request to mach has been made
    @objc dynamic var wasChargeAccepted: Bool = false

    //This variable is used to identify whether the tab bar tooltip has been shown. 
    @objc dynamic var wasTabBarTooltipShown: Bool = false

    convenience init(configurationResponse: ConfigurationResponse) {
        self.init()
        self.machId = configurationResponse.machProfile.machID
        self.name = configurationResponse.machProfile.name
        self.smallImageURLString = configurationResponse.machProfile.imageUrls.small
        self.mediumImageURLString = configurationResponse.machProfile.imageUrls.medium
        self.largeImageURLString = configurationResponse.machProfile.imageUrls.large
        self.maxContactsToTriggerInvitation = configurationResponse.maxContactsInvitation
        self.maxOnboardingRequestAmount = configurationResponse.onboarding.maxOnboardingRequestAmount
        self.maxContactsForGroup = configurationResponse.maxContactsForGroup
    }

    override static func primaryKey() -> String? {
        return "machId"
    }

    override var description: String {
        return ("machID:\(machId)")
    }
}
