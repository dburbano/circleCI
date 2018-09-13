//
//  CashoutATMModel.swift
//  machApp
//
//  Created by Rodrigo Russell on 1/18/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON
import RealmSwift

class CashoutATMModel: Object {

    @objc dynamic var machId: String?
    @objc dynamic var id: String?
    @objc dynamic var amount: Int = 0
    @objc dynamic var nigCode: String?
    @objc dynamic var pin: String?
    @objc dynamic var createdAt: Date?
    @objc dynamic var cancelledAt: Date?
    @objc dynamic var completedAt: Date?
    @objc dynamic var expiredAt: Date?
    @objc dynamic var expiresAt: Date?
    @objc dynamic var blockedAt: Date?

    convenience required init(cashout: CashoutATMResponse) {
        self.init()
        self.machId = AccountManager.sharedInstance.getMachId()
        self.id = cashout.id
        self.amount = cashout.amount
        self.nigCode = cashout.nigCode
        self.pin = cashout.pin
        self.createdAt = cashout.createdAt
        self.cancelledAt = cashout.cancelledAt
        self.completedAt = cashout.completedAt
        self.expiredAt = cashout.expiredAt
        self.expiresAt = cashout.expiresAt
        self.blockedAt = cashout.blockedAt
    }

    override static func primaryKey() -> String? {
        return "machId"
    }

}
