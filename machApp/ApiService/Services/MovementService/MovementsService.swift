//
//  MovementsService.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/4/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum MovementsService: Service {
    case getMovement(parameters: Parameters)
    case getHistory(parameters: Parameters)
}

extension MovementsService: URLRequestConvertible {
    static let serviceURL = "/mobile/movements"

    var method: HTTPMethod {
        switch self {
        case .getMovement, .getHistory:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getMovement(let parameter):
            //swiftlint:disable:next force_unwrapping
            return "/\(parameter.first!.value)"
        case .getHistory:
           return "/history"
        }

    }

    func asURLRequest() throws -> URLRequest {
        var baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
        let url = try baseURLString.appending(MovementsService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        switch self {
        case .getMovement:
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: nil)
        case .getHistory(let parameters):
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
        }
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}
