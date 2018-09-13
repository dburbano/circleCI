//
//  SignalService.swift
//  machApp
//
//  Created by lukas burns on 4/12/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum SignalService: Service {
    case online
    case subscribed
    case acknowledge(parameters: Parameters)
}

extension SignalService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/signals"

    var method: HTTPMethod {
        switch self {
        case .online:
            return .post
        case .subscribed:
            return .post
        case .acknowledge:
            return .post
        }
    }

    var path: String {
        switch self {
        case .online:
            return "/device/online"
        case .subscribed:
            return "/realtime/subscribed"
        case .acknowledge:
            return "/messages/ack"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try SignalService.baseURLString.appending(SignalService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 10

        switch self {
        case .online:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .subscribed:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .acknowledge(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }

        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
}
