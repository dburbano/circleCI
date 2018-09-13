//
//  Balance.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class Balance: Object {
    @objc dynamic var id: Int = 1
    @objc dynamic var balance: Float = 0.0
    @objc dynamic var lastRetrievedDate: Date = Date()

    convenience init(balanceResponse: BalanceResponse) {
        self.init()
        self.balance = balanceResponse.balance
        self.lastRetrievedDate = balanceResponse.lastRetrievedDate
    }

    convenience init(balance: Float, date: Date) {
        self.init()
        self.balance = balance
        self.lastRetrievedDate = date
    }

    //A primary key is set so that a single row is saved. Otherwise for each update a new Balance row would be created.
    override static func primaryKey() -> String? {
        return "id"
    }

    override var description: String {
        return ("Balance:\(balance) date:\(lastRetrievedDate)")
    }
}
