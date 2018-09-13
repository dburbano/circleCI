//
//  NearUser.swift
//  machApp
//
//  Created by lukas burns on 7/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap
import Unbox
import SwiftyJSON
import RealmSwift

class DeviceBeacon: Object, Unboxable {

    @objc dynamic var major: Int = 0
    @objc dynamic var minor: Int = 0

    public static func == (lhs: DeviceBeacon, rhs: DeviceBeacon) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor
    }

    public convenience required init(unboxer: Unboxer) throws {
        self.init()
        self.minor = try unboxer.unbox(key: "minor")
        self.major = try unboxer.unbox(key: "major")
    }

    public convenience init (major: Int, minor: Int) {
        self.init()
        self.minor = minor
        self.major = major
    }

    public static func create(from dictionary: JSON) throws -> DeviceBeacon {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: DeviceBeacon = try unbox(dictionary: dictionaryObject)
        return response
    }

}

extension DeviceBeacon: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "major" {
            return "major"
        }
        if propertyName == "minor" {
            return "minor"
        }
        return propertyName
    }

    public func toParams() throws -> [String : Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
