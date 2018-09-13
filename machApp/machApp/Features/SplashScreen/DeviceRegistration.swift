//
//  Payment.swift
//  machApp
//
//  Created by lukas burns on 2/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct DeviceRegistration {

    var deviceId: String?
    var deviceModel: String?
    var systemVersion: String?
    var deviceOS: String?
}

extension DeviceRegistration: WrapCustomizable {

    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "deviceId" {
            return "device_id"
        }
        if propertyName == "deviceModel" {
            return "device_model"
        }
        if propertyName == "systemVersion" {
            return "os_version"
        }
        if propertyName == "deviceOS" {
            return "device_os"
        }
        return propertyName
    }

    public func toParams() throws -> [String : Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
