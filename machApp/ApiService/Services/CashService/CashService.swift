//
//  CashService.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/19/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum CashService: Service {
    case banks
    case out(parameters: Parameters)
    case inscribeCreditCardWebPay
    case finishCreditCardInscription(parameters: Parameters)
    case getCreditCards
    case deleteCreditCard(token: String)
    case rechargeCreditCard(parameters: Parameters)
    case cashoutATM(parameters: Parameters)
    case deleteCashoutATM(id: String)
    case getCashoutATM
}

extension CashService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/cash"

    var method: HTTPMethod {
        switch self {
        case .banks:
            return .get
        case .out:
            return .post
        case .inscribeCreditCardWebPay:
            return .post
        case .finishCreditCardInscription:
            return .post
        case .getCreditCards:
            return .get
        case .deleteCreditCard:
            return .delete
        case .rechargeCreditCard:
            return .post
        case .cashoutATM:
            return .post
        case .deleteCashoutATM:
            return .delete
        case .getCashoutATM:
            return .get
        }
    }

    var path: String {
        switch self {
        case .banks:
            return "/banks"
        case .out:
            return "/out"
        case .inscribeCreditCardWebPay:
            return "/webpay-oneclick/init-inscription"
        case .finishCreditCardInscription:
            return "/webpay-oneclick/finish-inscription"
        case .getCreditCards:
            return "/webpay-oneclick/inscriptions"
        case .deleteCreditCard(let token):
            return "/webpay-oneclick/inscriptions/\(token)"
        case .rechargeCreditCard:
            return "/in/webpay-oneclick"
        case .cashoutATM:
            return "/out/atm"
        case .deleteCashoutATM(let id):
            return "/out/atm/\(id)"
        case .getCashoutATM:
            return "/out/atm/last"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try CashService.baseURLString.appending(CashService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 15

        switch self {
        case .banks:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .out(let parameters):
            let encryptedParameters = APISecurityManager.sharedInstance.encryptParameters(parameters: parameters)
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: encryptedParameters)
        case .inscribeCreditCardWebPay:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .finishCreditCardInscription(let parameters):
             urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .getCreditCards:
             urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .deleteCreditCard:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .rechargeCreditCard(let parameters):
            urlRequest.timeoutInterval = 45
            let encryptedParameters = APISecurityManager.sharedInstance.encryptParameters(parameters: parameters)
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: encryptedParameters)
        case .cashoutATM(let parameters):
            let encryptedParameters = APISecurityManager.sharedInstance.encryptParameters(parameters: parameters)
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: encryptedParameters)
        case .deleteCashoutATM:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        case .getCashoutATM:
            urlRequest = try JSONEncoding.default.encode(urlRequest)
        }
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}
