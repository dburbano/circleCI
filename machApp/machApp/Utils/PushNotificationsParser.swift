//
//  PushNotificationsParser.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class PushNotificationsParser {

    static let sharedInstance = PushNotificationsParser()

    private init() {}

    @discardableResult
    func handleNotification(_ userInfo: [AnyHashable: Any]) -> DeeplinkType? {
        if let data = userInfo[Constants.PushNotificationsConstants.PushStructure.data] as? [String: Any] {
            if let chatDetail = data[Constants.PushNotificationsConstants.PushStructure.deeplinkData] as? String, let universalLink = URL(string: chatDetail) {
                return DeeplinkParser.shared.parse(universalLink)
            }
        }
        return nil
    }
}
