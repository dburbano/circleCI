//
//  SiftScienceManager.swift
//  machApp
//
//  Created by Rodrigo Russell on 3/8/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Sift

class SiftScienceManager: NSObject {

    static let sharedInstance: SiftScienceManager = SiftScienceManager()
    let sift = Sift.sharedInstance

    fileprivate let accountId = "5a42a7334f0ca3aaca7a99a3"
    fileprivate let beaconKey = "d1bbf68159"

    fileprivate override init() {
        sift().accountId = self.accountId
        sift().beaconKey = self.beaconKey
    }

    func start() {

    }

    func setUserId(userId: String) {
        sift().userId = userId
    }

}
