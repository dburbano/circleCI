//
//  CashService.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/19/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum ContactService: Service {
    case upload(parameters: Parameters)
    case uploadContacts(parameters: Parameters)
}

extension ContactService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/contacts"

    var method: HTTPMethod {
        switch self {
        case .upload:
            return .post
        case .uploadContacts:
            return .post
        }
    }

    var path: String {
        switch self {
        case .upload:
            return ""
        case .uploadContacts:
            return "/phone-contacts"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try CashService.baseURLString.appending(ContactService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 10

        switch self {
        case .upload(let parameters), .uploadContacts(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}
