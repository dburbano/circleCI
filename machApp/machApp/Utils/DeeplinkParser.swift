//
//  DeeplinkParser.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class DeeplinkParser {
    static let shared = DeeplinkParser()
    private init() {}

    func parse(_ url: URL) -> DeeplinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            return nil
        }
        var pathComponents = components.path.components(separatedBy: "/")
        
        // Remove unwanted space at begining
        pathComponents.remove(at: 0)
        return DeeplinkType(host: host, path: pathComponents)
    }

}
