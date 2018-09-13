//
//  ExceptionManager.swift
//  machApp
//
//  Created by Lukas Burns on 1/8/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class ExceptionManager {
    static let sharedInstance = ExceptionManager()
    
    private init() {}
    
    func recordError(_ error: Error, with data: [AnyHashable: Any]? = nil) {
        //NewRelic.recordHandledException(exception)
        var attributes: [AnyHashable: Any] = [:]
        if let machId = AccountManager.sharedInstance.getMachId() {
            attributes["mach_id"] = machId
        }
        attributes["data"] = data
        NewRelic.recordError(error, attributes: data)
    }
}
