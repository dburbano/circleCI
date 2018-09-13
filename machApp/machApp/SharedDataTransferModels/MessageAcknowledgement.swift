//
//  TransactionAcknowledge.swift
//  machApp
//
//  Created by lukas burns on 5/29/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct MessageAcknowledgement {

    var messageId: String

    public init(messageId: String) {
        self.messageId = messageId
    }
}

extension MessageAcknowledgement: WrapCustomizable {

    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "messageId" {
            return "message_id"
        }
        return propertyName
    }

    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
