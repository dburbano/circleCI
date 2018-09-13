//
//  NotificationService.swift
//  machApp
//
//  Created by lukas burns on 3/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum PhoneVerificationService: Service {
    case request(parameters: Parameters)
    case verify(parameters: Parameters)
    case call(parameters: Parameters)
    case resend(parameters: Parameters)
}

extension PhoneVerificationService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/phone/verification"

    var method: HTTPMethod {
        switch self {
        case .request:
            return .post
        case .verify:
            return .post
        case .call:
            return .post
        case .resend:
            return .post
        }
    }

    var path: String {
        switch self {
        case .request:
            return "/request"
        case .verify:
            return "/check"
        case .call(let parameter):
            //swiftlint:disable:next force_unwrapping
            return "/call/\(parameter.first!.value)"
        case .resend(let parameter):
            var params = parameter
            params.removeValue(forKey: "phone")
            //swiftlint:disable:next force_unwrapping
            return "/request/\(params.first!.value)"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try PhoneVerificationService.baseURLString.appending(PhoneVerificationService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 10

        switch self {
        case .request(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .verify(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .call:
            break
        case .resend(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }

        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
}
