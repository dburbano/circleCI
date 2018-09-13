//
//  RequestUpdate.swift
//  machApp
//
//  Created by lukas burns on 5/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

struct RequestUpdate {
    var transactionId: String

    public init(transactionId: String) {
        self.transactionId = transactionId
    }
}

extension RequestUpdate: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "transactionId" {
            return "transactionId"
        }
        return propertyName
    }

    public func toParams() throws -> [String : Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
