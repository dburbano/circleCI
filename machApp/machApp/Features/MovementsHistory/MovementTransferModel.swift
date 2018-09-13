//
//  MovementTransferModel.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/4/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct MovementTransferModel {
    var id: String?

    public init(id: String) {
        self.id = id
    }
}

extension MovementTransferModel: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "id" {
            return "id"
        }
        return propertyName
    }

    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }

}
