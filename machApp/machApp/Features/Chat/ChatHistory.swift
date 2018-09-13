//
//  ChatHistory.swift
//  machApp
//
//  Created by lukas burns on 6/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct ChatHistory {
    var groupId: String
    var lastUpdatedAt: String?
    var lastId: String?
}

extension ChatHistory: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "groupId" {
            return "group_id"
        }
        if propertyName == "lastUpdatedAt" {
            return "last_updated_at"
        }
        if propertyName == "lastId" {
            return "last_id"
        }
        return propertyName
    }

    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
