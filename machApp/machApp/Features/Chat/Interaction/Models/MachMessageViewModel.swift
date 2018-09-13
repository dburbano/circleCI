//
//  MachMessageViewModel.swift
//  machApp
//
//  Created by lukas burns on 8/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class MachMessageViewModel: ChatMessageBaseViewModel {
    var machMessage: MachMessage
    var title: String?

    required init(machMessage: MachMessage) {
        self.machMessage = machMessage
        let createdAt = machMessage.createdAt as Date?
        var fromUserViewModel: UserViewModel? = nil
        if let fromUser = machMessage.fromUser {
            fromUserViewModel = UserViewModel(user: fromUser)
        }
        super.init(groupId: machMessage.groupId, seen: machMessage.seen, amount: machMessage.amount, message: machMessage.message, createdAt: createdAt, fromUser: fromUserViewModel, updatedAt: machMessage.updatedAt)
        self.title = machMessage.title
    }
}
