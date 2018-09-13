//
//  ImageUrlsResponse.swift
//  machApp
//
//  Created by lukas burns on 6/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON
import RealmSwift

class Images: Object, Unboxable {

    @objc dynamic var small: String?
    @objc dynamic var medium: String?
    @objc dynamic var large: String?

    convenience required init(unboxer: Unboxer) throws {
        self.init()
        self.small = unboxer.unbox(key: "small")
        self.medium = unboxer.unbox(key: "medium")
        self.large = unboxer.unbox(key: "large")
    }

    convenience init(smallImage: String) {
        self.init()
        self.small = smallImage
    }
}
