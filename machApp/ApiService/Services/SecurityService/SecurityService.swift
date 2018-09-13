//
//  CashService.swift
//  machApp
//
//  Created by Lukas Burns on 5/19/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum SecurityService: Service {
    case keys(parameters: Parameters)
}

extension SecurityService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile"

    var method: HTTPMethod {
        switch self {
        case .keys:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .keys:
            return "/keys"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try CashService.baseURLString.appending(SecurityService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 15

        switch self {
        case .keys(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }

}
