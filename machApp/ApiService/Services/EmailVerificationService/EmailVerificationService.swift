//
//  EmailVerificationService.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 2/8/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum EmailVerificationService: Service {
    case request

}

extension EmailVerificationService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/email-verification"

    var method: HTTPMethod {
        switch self {
        case .request:
            return .post
        }
    }

    var path: String {
        switch self {
        case .request:
            return "/request"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try EmailVerificationService.baseURLString.appending(EmailVerificationService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 10

        switch self {
        case .request:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        }

        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}
