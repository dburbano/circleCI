//
//  DeviceService.swift
//  machApp
//
//  Created by lukas burns on 3/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum DeviceService: Service {
    case identify(parameters: Parameters)
}

extension DeviceService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/devices"

    var method: HTTPMethod {
        switch self {
        case .identify:
            return .post
        }
    }

    var path: String {
        switch self {
        case .identify:
            return ""
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try DeviceService.baseURLString.appending(DeviceService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 10

        switch self {
        case .identify(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }

        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
}
