//
//  SignUpDateService.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/11/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum SignupDateService: Service {
    case getDate()
}

extension SignupDateService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/accounts/register/date"

    var method: HTTPMethod {
        switch self {
        case .getDate:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getDate:
            return ""
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try SignupDateService.baseURLString.appending(SignupDateService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 10

        switch self {
        case .getDate:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        }
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}
