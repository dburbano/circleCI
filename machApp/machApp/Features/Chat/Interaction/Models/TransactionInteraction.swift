//
//  TransactionReactions.swift
//  machApp
//
//  Created by lukas burns on 10/24/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class TransactionInteraction: Object {
    @objc dynamic var interaction: Interaction?
    @objc dynamic var date: Date?
    @objc dynamic var reactedBy: String?
    @objc dynamic var availableAt: Date?
    var triesRemaining = RealmOptional<Int>()

    convenience init(interaction: Interaction, date: Date, reactedBy: String?, availableAt: Date?, triesRemaining: Int?) {
        self.init()
        self.interaction = interaction
        self.date = date
        self.reactedBy = reactedBy
        self.availableAt = availableAt
        self.triesRemaining.value = triesRemaining
    }

}
