//
//  NotificationService.swift
//  machApp
//
//  Created by lukas burns on 3/30/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum NotificationeService: Service {
    case registerDevice(parameters: Parameters)
}

extension NotificationeService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/notifications"

    var method: HTTPMethod {
        switch self {
        case .registerDevice:
            return .post
        }
    }

    var path: String {
        switch self {
        case .registerDevice:
            return "/devices"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try NotificationeService.baseURLString.appending(NotificationeService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 10

        switch self {
        case .registerDevice(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }

        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
}
