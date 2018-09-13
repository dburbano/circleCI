//
//  ZendeskManager.swift
//  machApp
//
//  Created by Nicolas Palmieri on 6/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import MachZendesk


class ZendeskManager: NSObject {
    static let sharedInstance: ZendeskManager = ZendeskManager()
    fileprivate let zendeskURL = "https://machhelp.zendesk.com"
    fileprivate let clientId = "mobile_sdk_client_9f28783dac3b39a643e0"
    fileprivate let appId = "5eacc33ed6df69dee41b72ad35ddfa2c78a045e7d5b09bf4"
    fileprivate var kDBToken: String!
    fileprivate var sessionStatus: Bool = false

    fileprivate override init() {
        super.init()
    }
    
    func openHelpCenter(in viewController: UIViewController) {
        HelpCenter.Builder()
            .setZendesk(viewController, self.zendeskURL, self.appId, self.clientId)
            .setIdentity("", HelpCenter.Access.anonymous)
            .setDefaultScreen()
            .start()
    }
    
    func openArticle(in viewController: UIViewController, articleTags: [String]) {
        HelpCenter.Builder()
            .setZendesk(viewController, self.zendeskURL, self.appId, self.clientId)
            .setIdentity("", HelpCenter.Access.anonymous)
            .setTagScreen(articleTags)
            .start()
    }
    
    func openTicket(in viewController: UIViewController, ticketId: String) {
        HelpCenter.Builder()
            .setZendesk(viewController, self.zendeskURL, self.appId, self.clientId)
            .setIdentity("", HelpCenter.Access.anonymous)
            .setTicketScreen(ticketId)
            .start()
    }

}
