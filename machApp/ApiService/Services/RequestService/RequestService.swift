//
//  RequestServices.swift
//  machApp
//
//  Created by lukas burns on 5/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum RequestService: Service {
    case create(parameters: Parameters)
    case accept(parameters: Parameters)
    case cancel(parameters: Parameters)
    case reject(parameters: Parameters)
    case remind(parameters: Parameters)
}

extension RequestService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/requests"

    var method: HTTPMethod {
        switch self {
        case .create:
            return .post
        case .accept:
            return .post
        case .cancel:
            return .post
        case .reject:
            return .post
        case .remind:
            return .post
        }
    }

    var path: String {
        switch self {
        case .create:
            return ""
        case .accept(let parameters):
            //swiftlint:disable:next force_unwrapping
            return "/\(parameters.first!.value)/accept"
        case .cancel(let parameters):
            //swiftlint:disable:next force_unwrapping
            return "/\(parameters.first!.value)/cancel"
        case .reject(var parameters):
            let transactionId = parameters["transactionId"]
            return "/\(transactionId ?? "")/reject"
        case .remind(var parameters):
            let transactionId = parameters["transactionId"]
            return "/\(transactionId ?? "")/remind"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try RequestService.baseURLString.appending(RequestService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 10

        switch self {
        case .create(let parameters):
            let encryptedParameters = APISecurityManager.sharedInstance.encryptParameters(parameters: parameters)
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: encryptedParameters)
        case .accept:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .cancel:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .reject(var parameters):
            parameters.removeValue(forKey: "transactionId")
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .remind(var parameters):
            parameters.removeValue(forKey: "transactionId")
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }

        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
}
