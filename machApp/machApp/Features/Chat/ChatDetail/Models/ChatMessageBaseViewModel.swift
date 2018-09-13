//
//  ChatMessageBaseViewModel.swift
//  machApp
//
//  Created by lukas burns on 8/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class ChatMessageBaseViewModel: NSObject {
    var groupId: String?
    var seen: Bool?
    var amount: Int = 0
    var message: String?
    var createdAt: Date?
    var updatedAt: Date?
    var fromUser: UserViewModel?

    init(groupId: String?, seen: Bool?, amount: Int, message: String?, createdAt: Date?, fromUser: UserViewModel?, updatedAt: Date?) {
        self.groupId = groupId
        self.seen = seen
        self.amount = amount
        self.message = message
        self.createdAt = createdAt
        self.fromUser = fromUser
        self.updatedAt = updatedAt
    }
    
}
