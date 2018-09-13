//
//  ProfileService.swift
//  machApp
//
//  Created by lukas burns on 3/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum ProfileService: Service {
    case register(parameters: Parameters)
    case get(parameters: Parameters)
    case me
    case upload
    case nearby(parameters: Parameters)
}

extension ProfileService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/profiles"

    var method: HTTPMethod {
        switch self {
        case .register:
            return .post
        case .get:
            return .get
        case .upload:
            return .post
        case .me:
            return .get
        case .nearby:
            return .post
        }
    }

    var path: String {
        switch self {
        case .register:
            return ""
        case .get(let parameter):
            //swiftlint:disable:next force_unwrapping
            return "/\(parameter.first!.value)"
        case .me:
            return "/me"
        case .upload:
            return "/images"
        case .nearby:
            return "/nearby"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try ProfileService.baseURLString.appending(ProfileService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 60

        switch self {
        case .register(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .get( _):
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .me:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .upload:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .nearby(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }

        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
}
