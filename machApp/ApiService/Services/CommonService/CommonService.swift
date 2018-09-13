//
//  PrepaidCardService.swift
//  machApp
//
//  Created by Lukas Burns on 3/19/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum CommonService: Service {
    case getUSDExchangeRate()
}

extension CommonService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile"
    
    var method: HTTPMethod {
        switch self {
        case .getUSDExchangeRate:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getUSDExchangeRate:
            return "/fx/usd/visa"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try CommonService.baseURLString.appending(CommonService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 10
        
        switch self {
        case .getUSDExchangeRate:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
            urlRequest.cachePolicy = .reloadIgnoringCacheData
        }

        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
}
