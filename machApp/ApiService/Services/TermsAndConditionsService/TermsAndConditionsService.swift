//
//  TermsAndConditions.swift
//  machApp
//
//  Created by lukas burns on 8/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum TermsAndConditionsService: Service {
    case get
    case accept(parameters: Parameters)
}

extension TermsAndConditionsService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/terms-and-conditions"

    var method: HTTPMethod {
        switch self {
        case .get:
            return .get
        case .accept:
            return .post
        }
    }

    var path: String {
        switch self {
        case .get:
            return ""
        case .accept:
            return "/accept"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try CashService.baseURLString.appending(TermsAndConditionsService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 10

        switch self {
        case .get:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .accept(let params):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: params)
        }
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}
