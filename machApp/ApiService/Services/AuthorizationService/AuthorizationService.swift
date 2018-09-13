//
//  AuthenticationService.swift
//  machApp
//
//  Created by lukas burns on 2/15/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum AuthorizationService: Service {
    case refreshToken(parameters: Parameters)
}

extension AuthorizationService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/auth"

    var method: HTTPMethod {
        switch self {
        case .refreshToken:
            return .post
        }
    }

    var path: String {
        switch self {
        case .refreshToken:
            return "/refresh"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try AuthorizationService.baseURLString.appending(AuthorizationService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 20

        switch self {
        case .refreshToken(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }

        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }

}
