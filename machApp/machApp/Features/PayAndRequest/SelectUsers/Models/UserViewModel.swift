//
//  UserViewModel.swift
//  machApp
//
//  Created by lukas burns on 4/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class UserViewModel: NSObject {

    var user: User

    var machFirstName: String { return self.user.firstName ?? "" }

    var machLastName: String { return self.user.lastName ?? "" }

    var phone: String { return self.user.phone ?? "" }

    var email: String { return self.user.email ?? "" }

    var phoneFirstName: String { return self.user.firstNamePhone ?? "" }

    var phoneLastName: String { return self.user.lastNamePhone ?? "" }

    var machId: String? { return self.user.machId }

    var isInContacts: Bool { return self.user.isInContacts }

    var isNear: Bool

    var isMach: Bool { return user.machId != nil }

    var firstNameToShow: String {
        if isInContacts {
            return phoneFirstName
        } else if isNear || phone.isBlank || (machId != nil && machId == ConfigurationManager.sharedInstance.getMachTeamConfiguration()?.machId) {
            return machFirstName
        } else {
            return phone.formatAsPhoneNumber()
        }
    }

    var lastNameToShow: String {
        if isInContacts {
            return phoneLastName
        } else if isNear || phone.isBlank || (machId != nil && machId == ConfigurationManager.sharedInstance.getMachTeamConfiguration()?.machId) {
            return machLastName
        } else {
            return ""
        }
    }

    var profileImageUrl: URL? {
        if let imageUrl = self.user.images?.small {
            return URL(string: imageUrl)
        } else {
            return nil
        }
    }

    var profileImage: UIImage? {
        if isInContacts {
            return UIView.getAvatar(phoneNumber: user.phone, firstName: user.firstNamePhone, lastName: user.lastNamePhone).asImage()
        } else {
            return UIView.getAvatar(phoneNumber: user.phone, firstName: user.firstName, lastName: user.lastName).asImage()
        }
    }

    init(user: User) {
        self.user = user
        self.isNear = false
    }

}
