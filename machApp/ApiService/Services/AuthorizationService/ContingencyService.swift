//
//  ContingencyService.swift
//  machApp
//
//  Created by Lukas Burns on 7/18/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum ContingencyService: Service {
    case contingencyStatus
    case issueContingencyToken
    case exchangeContingencyToken(contingencyToken: String)
}

extension ContingencyService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let contingencyURLString = AlamofireNetworkLayer.sharedInstance.getContingencyURL()
    static let serviceURL = "/mobile"
    
    var method: HTTPMethod {
        switch self {
        case .contingencyStatus:
            return .get
        case .issueContingencyToken:
            return .get
        case .exchangeContingencyToken:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .contingencyStatus:
            return "/contingency"
        case .issueContingencyToken, .exchangeContingencyToken:
            return "/auth/contingency"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try ContingencyService.baseURLString.appending(ContingencyService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 20
        
        switch self {
        case .contingencyStatus:
            let contingencyUrl = try ContingencyService.contingencyURLString.appending(ContingencyService.serviceURL).asURL()
            let contingencyRequest = URLRequest(url: contingencyUrl.appendingPathComponent(path))
            urlRequest = try JSONEncoding.default.encode(contingencyRequest)
        case .issueContingencyToken:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .exchangeContingencyToken(let contingencyToken):
            let contingencyUrl = try ContingencyService.contingencyURLString.appending(ContingencyService.serviceURL).asURL()
            let contingencyRequest = URLRequest(url: contingencyUrl.appendingPathComponent(path))
            urlRequest = try JSONEncoding.default.encode(contingencyRequest, with: ["contingency_token": contingencyToken])
        }

        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
    
}
