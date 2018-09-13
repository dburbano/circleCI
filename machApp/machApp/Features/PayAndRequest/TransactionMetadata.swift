//
//  TransactionMetadata.swift
//  machApp
//
//  Created by lukas burns on 7/20/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift
import Unbox
import SwiftyJSON
import Wrap

// Class intended to encapsulate the way that the transaction was created, ie: bluetooh
class TransactionMetadata: Object, Unboxable {

    @objc dynamic var originatedBy: String?

    convenience required init(unboxer: Unboxer) throws {
        self.init()
        self.originatedBy = unboxer.unbox(key: "originated_by")
    }

    convenience init (originatedBy: String) {
        self.init()
        self.originatedBy = originatedBy
    }
}

extension TransactionMetadata: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "originatedBy" {
            return "originated_by"
        }
        return propertyName
    }

    public func toParams() throws -> [String : Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
