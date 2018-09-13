//
//  IdentityService.swift
//  machApp
//
//  Created by lukas burns on 3/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum IdentityService: Service {
    case verify(parameters: Parameters)
    case createTEFVerification(parameters: Parameters)
    case getLastTEFVerification
    case checkTEFVerification(parameters: Parameters)
}

extension IdentityService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/identities"

    var method: HTTPMethod {
        switch self {
        case .verify:
            return .post
        case .createTEFVerification:
            return .post
        case .getLastTEFVerification:
            return .get
        case .checkTEFVerification:
            return .post
        }
    }

    var path: String {
        switch self {
        case .verify:
            return "/verification"
        case .createTEFVerification, .getLastTEFVerification:
            return "/tef/verification"
        case .checkTEFVerification:
            return "/tef/verification/check"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try IdentityService.baseURLString.appending(IdentityService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 10

        switch self {
        case .verify(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .checkTEFVerification(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .getLastTEFVerification:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .createTEFVerification(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }

        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
}
