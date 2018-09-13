//
//  PrepaidCardService.swift
//  machApp
//
//  Created by Lukas Burns on 3/19/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum PrepaidCardService: Service {
    case getPrepaidCards()
    case getCVV(prepaidCardId: String)
    case getPAN(prepaidCardId: String)
    case generatePrepaidCard()
    case removePrepaidCard(prepaidCardId: String)
}

extension PrepaidCardService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/prepaid-cards"
    
    var method: HTTPMethod {
        switch self {
        case .getPrepaidCards:
            return .get
        case .getCVV, .getPAN:
            return .get
        case .generatePrepaidCard:
            return .post
        case .removePrepaidCard:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .getPrepaidCards, .generatePrepaidCard:
            return ""
        case .removePrepaidCard(let prepaidCardId):
            return "/\(prepaidCardId)"
        case .getCVV(let prepaidCardId):
            return "/\(prepaidCardId)/cvv"
        case .getPAN(let prepaidCardId):
            return "/\(prepaidCardId)/pan"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try PrepaidCardService.baseURLString.appending(PrepaidCardService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 45
        
        switch self {
        case .getPrepaidCards, .generatePrepaidCard:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .getPAN, .getCVV, .removePrepaidCard:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        }
        
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
}
