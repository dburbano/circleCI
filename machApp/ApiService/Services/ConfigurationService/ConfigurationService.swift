//
//  ConfigService.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/12/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum ConfigurationService: Service {
    case getConfiguration
    case healthCheck
}

extension ConfigurationService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile"

    var method: HTTPMethod {
        switch self {
        case .getConfiguration:
            return .get
        case .healthCheck:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getConfiguration:
            return "/config"
        case .healthCheck:
            return "/healthcheck"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try ConfigurationService.baseURLString.appending(ConfigurationService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        switch self {
        case .getConfiguration:
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: nil)
        case .healthCheck:
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: nil)
            urlRequest.addValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: "mach-header-id")
        }
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}
