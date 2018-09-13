//
//  Reaction.swift
//  machApp
//
//  Created by lukas burns on 10/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class Interaction: Object {
    @objc dynamic var id: String?
    @objc dynamic var imageUri: String?
    @objc dynamic var message: String?
    @objc dynamic var type: String?

    convenience init(id: String, imageUri: String, message: String, type: String) {
        self.init()
        self.id = id
        self.imageUri = imageUri
        self.message = message
        self.type = type
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
