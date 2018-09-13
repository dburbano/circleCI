//
//  DeepLinkManager.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

enum DeeplinkType {
    case openGroup(groupId: String)
    case openMovement(groupId: String, movementId: String)
    case openCashIn()
    case openHome()
    case openMore()
    case openShare()
    case openProfile
    case request(userId: String, amount: Int?, comment: String?)
    case pay(userId: String, amount: Int?, comment: String?)
}

extension DeeplinkType {

    //swiftlint:disable:next cyclomatic_complexity
    init?(host: String, path: [String]) {
        var g = path.makeIterator()
        if host == "open" {
            switch(g.next(), g.next(), g.next(), g.next(), g.next(), g.next()) {
            case ("cashin"?, nil, nil, nil, nil, nil):
                self = .openCashIn()
            case ("home"?, nil, nil, nil, nil, nil):
                self = .openHome()
            case ("more"?, nil, nil, nil, nil, nil):
                self = .openMore()
            case ("share"?, nil, nil, nil, nil, nil):
                self = .openShare()
            case ("groups"?, let groupId?, nil, nil, nil, nil):
                self = .openGroup(groupId: groupId)
            case ("groups"?, let groupId?, "movements"?, let movementId?, nil, nil):
                self = .openMovement(groupId: groupId, movementId: movementId)
            case ("profile"?, nil, nil, nil, nil, nil):
                self = .openProfile
            default:
                return nil
            }
        } else if host == "pay" {
            switch(g.next(), g.next(), g.next(), g.next(), g.next(), g.next()) {
            case ("user"?, let userId?, "amount"?, let amount, "comment"?, let comment):
                self = .pay(userId: userId, amount: Int(amount ?? "0"), comment: comment )
            case ("user"?, let userId?, "amount"?, let amount, nil, nil):
                self = .pay(userId: userId, amount: Int(amount ?? "0"), comment: nil )
            case ("user"?, let userId?, "comment"?, let comment, nil, nil):
                self = .pay(userId: userId, amount: 0, comment: comment )
            case ("user"?, let userId?, nil, nil, nil, nil):
                self = .pay(userId: userId, amount: 0, comment: nil )
            default:
                return nil
            }
        } else if host == "request" {
            switch(g.next(), g.next(), g.next(), g.next(), g.next(), g.next()) {
            case ("user"?, let userId?, "amount"?, let amount, "comment"?, let comment):
                self = .request(userId: userId, amount: Int(amount ?? "0"), comment: comment )
            case ("user"?, let userId?, "amount"?, let amount, nil, nil):
                self = .pay(userId: userId, amount: Int(amount ?? "0"), comment: nil )
            case ("user"?, let userId?, "comment"?, let comment, nil, nil):
                self = .pay(userId: userId, amount: 0, comment: comment )
            case ("user"?, let userId?, nil, nil, nil, nil):
                self = .pay(userId: userId, amount: 0, comment: nil )
            default:
                return nil
            }
        } else {
            return nil
        }
    }

}

let deepLinker = DeeplinkManager()

class DeeplinkManager {

    private var deeplinkType: DeeplinkType?

    fileprivate init() {}

    func checkDeepLink() {
        guard let deeplinkType = deeplinkType else {
            return
        }
        Navigator.shared.proceedToDeeplink(type: deeplinkType)

        // reset deeplink after handling
        self.deeplinkType = nil
    }

    @discardableResult
    func handleDeepLink(url: URL) -> Bool {
        deeplinkType = DeeplinkParser.shared.parse(url)
        return deeplinkType != nil
    }

    func handleRemoteNotification(_ notification: [AnyHashable: Any]) {
        deeplinkType = PushNotificationsParser.sharedInstance.handleNotification(notification)
    }

}
