//
//  UserAmountViewModel.swift
//  machApp
//
//  Created by lukas burns on 3/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class UserAmountViewModel: UserViewModel {

    var amount: Int
    var isLocked: Bool
    var maximumAmount: Int?

    override init(user: User) {
        self.amount = 0
        isLocked = false
        super.init(user: user)
    }
}
