//
//  AuthenticationService.swift
//  machApp
//
//  Created by lukas burns on 2/15/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire

enum AuthenticationService: Service {
    case recoverAccount(parameters: Parameters)
    case verifyIdDocument(parameters: Parameters, processId: String)
    case requestSecurityQuestions(processId: String)
    case checkSecurityAnswers(parameters: Parameters, processId: String)
    case phoneVerification(parameters: Parameters, processId: String)
    case requestPhoneVerificationCall(parameters: Parameters, processId: String)
    case repeatPhoneVerificationCall(parameters: Parameters, processId: String)
    case checkSMSCode(parameters: Parameters, processId: String)
    case requestMail(processId: String)
    case getMailVerification(processId: String)
    case getAuthenticationProcess(authenticationGoal: String)
    case requestTef(parameters: Parameters, processId: String)
    case checkTef(parameters: Parameters, processId: String)
}

extension AuthenticationService: URLRequestConvertible {
    static let baseURLString = AlamofireNetworkLayer.sharedInstance.getBaseURL()
    static let serviceURL = "/mobile/authentication"
    
    var method: HTTPMethod {
        switch self {
        case .recoverAccount,
             .verifyIdDocument,
             .requestSecurityQuestions,
             .checkSecurityAnswers,
             .phoneVerification,
             .requestPhoneVerificationCall,
             .repeatPhoneVerificationCall,
             .checkSMSCode,
             .requestMail,
             .getMailVerification,
             .getAuthenticationProcess,
             .requestTef,
             .checkTef:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .recoverAccount:
            return "/recover-account"
        case .verifyIdDocument:
            return "/verify-id-document"
        case .requestSecurityQuestions:
            return "/request-security-questions"
        case .checkSecurityAnswers:
            return "/check-security-answers"
        case .phoneVerification:
            return "/request-phone-verification"
        case .requestPhoneVerificationCall:
            return "/request-phone-verification-call"
        case .repeatPhoneVerificationCall:
            return "/repeat-phone-verification"
        case .checkSMSCode:
            return "/check-phone-verification"
        case .requestMail:
            return "/request-email-verification"
        case .getMailVerification:
            return "/get-email-verification-status"
        case .getAuthenticationProcess:
            return ""
        case .requestTef:
            return "/request-tef-verification"
        case .checkTef:
            return "/check-tef-verification"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try AuthenticationService.baseURLString.appending(AuthenticationService.serviceURL).asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.timeoutInterval = 20
        
        switch self {
        case .recoverAccount(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .verifyIdDocument(var parameters, let processId),
             .checkSecurityAnswers(var parameters, let processId),
             .phoneVerification(var parameters, let processId),
             .requestPhoneVerificationCall(var parameters, let processId),
             .repeatPhoneVerificationCall(var parameters, let processId),
             .checkSMSCode(var parameters, let processId),
             .requestTef(var parameters, let processId),
             .checkTef(var parameters, let processId):
            parameters["process_id"] = processId
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .requestSecurityQuestions(let processId):
            let parameter = ["process_id": processId]
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameter)
        case .requestMail(let processId), .getMailVerification(let processId):
            let parameter = ["process_id": processId]
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameter)
            urlRequest.timeoutInterval = 5
        case .getAuthenticationProcess(let goal):
            let parameter = ["goal": goal]
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameter)
        }
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}
