//
//  OnboardingService.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/19/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum OnboardingService: Service {
    case create(parameters: Parameters)
}

extension OnboardingService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/loyalty/onboarding/payment-request"

    var method: HTTPMethod {
        switch self {
        case .create:
            return .post
        }
    }

    var path: String {
        switch  self {
        case .create:
            return ""
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try RequestService.baseURLString.appending(OnboardingService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 10

        switch self {
        case .create(let parameters):
            let encryptedParameters = APISecurityManager.sharedInstance.encryptParameters(parameters: parameters)
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: encryptedParameters)
        }

        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
}
