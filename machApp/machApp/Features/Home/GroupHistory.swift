//
//  GroupHistory.swift
//  machApp
//
//  Created by lukas burns on 6/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct GroupHistory {
    var lastGroupId: String?
}

extension GroupHistory: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "lastGroupId" {
            return "last_group_id"
        }
        return propertyName
    }

    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
