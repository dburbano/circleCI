//
//  PaymentService.swift
//  machApp
//
//  Created by lukas burns on 3/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum PaymentService: Service {
    case create(parameters: Parameters)
    case react(parameters: Parameters)
}

extension PaymentService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/payments"

    var method: HTTPMethod {
        switch self {
        case .create:
            return .post
        case .react:
            return .post
        }
    }

    var path: String {
        switch self {
        case .create:
            return ""
        case .react(var parameters):
            let transactionId = parameters["transactionId"]
            return "/\(transactionId ?? "")/react"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try PaymentService.baseURLString.appending(PaymentService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 45

        switch self {
        case .create(let parameters):
            let encryptedParameters = APISecurityManager.sharedInstance.encryptParameters(parameters: parameters)
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: encryptedParameters)
        case .react(var parameters):
            parameters.removeValue(forKey: "transactionId")
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }

        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
}
