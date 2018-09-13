//
//  DeviceNotificationInformation.swift
//  machApp
//
//  Created by lukas burns on 3/30/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct DeviceNotificationInformation {
    var deviceToken: String
    var platform: String = "ios"

    public init (deviceToken: String) {
        self.deviceToken = deviceToken
    }
}

extension DeviceNotificationInformation: WrapCustomizable {

    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "deviceToken" {
            return "device_notifications_id"
        }
        if propertyName == "platform" {
            return "operating_system"
        }
        return propertyName
    }

    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
