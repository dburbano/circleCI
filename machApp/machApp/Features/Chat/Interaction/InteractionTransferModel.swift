//
//  InteractionTransferModel.swift
//  machApp
//
//  Created by lukas burns on 11/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct InteractionTransferModel {

    var transactionId: String
    var interactionId: String

    public init(transactionId: String, interactionId: String) {
        self.transactionId = transactionId
        self.interactionId = interactionId
    }
}

extension InteractionTransferModel: WrapCustomizable {

    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "transactionId" {
            return "transactionId"
        }
        if propertyName == "interactionId" {
            return "reactionId"
        }
        return propertyName
    }

    public func toParams() throws -> [String : Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
