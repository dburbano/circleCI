//
//  SelectUserViewModel.swift
//  machApp
//
//  Created by lukas burns on 3/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class SelectUserViewModel: UserViewModel {
    var isSelected: Bool
    var major: Int { return user.deviceBeacon?.major ?? 0 }
    var minor: Int { return user.deviceBeacon?.minor ?? 0 }
    var noShowCount: Int

    var isFirstNameFirst: Bool { return true}

    override init(user: User) {
        self.isSelected = false
        self.noShowCount = 0
        super.init(user: user)
    }

    func wasFoundNear(isFound: Bool) {
        if isFound {
            noShowCount = 0
        } else {
            noShowCount += 1
        }
    }

    func shouldRemoveFromNearUsers() -> Bool {
        if noShowCount > 3 {
            noShowCount = 0
            return true
        }
        return false
    }
}
