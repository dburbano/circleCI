//
//  PrepaidCard.swift
//  machApp
//
//  Created by Lukas Burns on 3/19/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

enum PrepaidCardState: String {
    case pending
    case active
    case deleting
}

class PrepaidCard: Object {
    @objc dynamic var id: String?
    @objc dynamic var last4Pan: String?
    @objc dynamic var holderName: String?
    @objc dynamic var expirationYear: String?
    @objc dynamic var expirationMonth: String?
    @objc dynamic var state: String?
    @objc var pan: String?
    @objc var cvv: String?
    
    var getState: PrepaidCardState? {
        return PrepaidCardState(rawValue: state ?? "")
    }
    
    convenience init(id: String, last4Pan: String?, holderName: String?, expirationYear: String?, expirationMonth: String?, state: String?) {
        self.init()
        self.id = id
        self.last4Pan = last4Pan
        self.holderName = holderName
        self.expirationYear = expirationYear
        self.expirationMonth = expirationMonth
        self.state = state
    }
    
    convenience init(prepaidCardResponse: PrepaidCardResponse) {
        self.init()
        self.id = prepaidCardResponse.id
        self.last4Pan = prepaidCardResponse.last4Pan
        self.holderName = prepaidCardResponse.holderName
        self.expirationYear = prepaidCardResponse.expirationYear
        self.expirationMonth = prepaidCardResponse.expirationMonth
        self.state = prepaidCardResponse.state
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
