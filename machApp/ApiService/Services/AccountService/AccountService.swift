//
//  AccountService.swift
//  machApp
//
//  Created by lukas burns on 3/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum AccountService: Service {
    case balance()
    case groupHistory(params: Parameters)
    case chatHistory(params: Parameters)
    case information()
    case recover(params: Parameters)
    case sendRecoverInformation(params: Parameters)
    case create()
}

extension AccountService: URLRequestConvertible {
    static let serviceURL = "/mobile/accounts"

    var method: HTTPMethod {
        switch self {
        case .balance:
            return .get
        case .groupHistory:
            return .get
        case .chatHistory:
            return .get
        case .information:
            return .get
        case .recover:
            return .post
        case .sendRecoverInformation:
            return .post
        case .create:
            return .post
        }
    }

    var path: String {
        switch self {
        case .balance:
            return "/balance"
        case .groupHistory:
            return "/history"
        case .chatHistory(let parameter):
            let groupId = parameter["group_id"]
            return "/history/\(groupId!)"
        case .information:
            return "/information"
        case .recover:
            return "/recover/request"
        case .sendRecoverInformation:
            return "/recover/check"
        case .create:
            return ""
        }
    }

    func asURLRequest() throws -> URLRequest {
        let baseUrl = AlamofireNetworkLayer.sharedInstance.getBaseURL()
        let url = try baseUrl.appending(AccountService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        switch self {
        case .balance:
            urlRequest.timeoutInterval = 30
        default:
            urlRequest.timeoutInterval = 10
        }

        switch self {
        case .balance():
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: nil)
        case .chatHistory(let parameters):
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
        case .groupHistory(let parameters):
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
        case .information():
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: nil)
        case .recover(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .sendRecoverInformation(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .create():
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        }

        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
}
