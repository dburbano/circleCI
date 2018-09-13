//
//  AlamoFireNetworkLayer.swift
//  machApp
//
//  Created by lukas burns on 2/15/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct AlamofireNetworkLayer: APIServiceProtocol {

    static var sharedInstance: AlamofireNetworkLayer = AlamofireNetworkLayer()

    var sessionManager: SessionManager?
    var oAuthHandler: OAuth2Handler?
    var authTokenManager: AuthTokenManagerProtocol
    
    var isInContingency: Bool = false

    let serverTrustPolicies: [String: ServerTrustPolicy] = [
        "api-dev.soymach.com": .pinCertificates(
            certificates: ServerTrustPolicy.certificates(),
            validateCertificateChain: true,
            validateHost: true
        ),
        "api-staging.soymach.com": .pinCertificates(
            certificates: ServerTrustPolicy.certificates(),
            validateCertificateChain: true,
            validateHost: true
        ),
        "api.soymach.com": .pinCertificates(
            certificates: ServerTrustPolicy.certificates(),
            validateCertificateChain: true,
            validateHost: true
        )
    ]

    private init() {
        self.authTokenManager = AuthTokenManager.sharedInstance
        self.oAuthHandler = OAuth2Handler(baseURLString: self.getBaseURL(), authTokenManager: self.authTokenManager)
        sessionManager = SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
        sessionManager?.adapter = oAuthHandler
        sessionManager?.retrier = oAuthHandler
    }
    
    public init(contingencyMode: Bool) {
        self.authTokenManager = ContingencyTokenManager.sharedInstance
        self.oAuthHandler = OAuth2Handler(baseURLString: self.getContingencyURL(), authTokenManager: self.authTokenManager)
        sessionManager = SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
        sessionManager?.adapter = oAuthHandler
        sessionManager?.retrier = oAuthHandler
        self.isInContingency = true
    }

    internal func request(_ service: Service, onSuccess: @escaping (NetworkResponse) -> Void, onError: @escaping (NetworkError) -> Void) {
        guard let service = service as? URLRequestConvertible else { return }
        print(service.urlRequest ?? "No url request in response")
        sessionManager?.request(service).validate().responseJSON { response in
            /*Uncomment this line if you want to see the request's body
             print(NSString(data: (response.request?.httpBody)!, encoding: String.Encoding.utf8.rawValue)!)*/
            switch response.result {
            case .success:
                self.oAuthHandler?.saveTokens(response: response)
                onSuccess(NetworkResponse(response: response))
            case .failure:
                // First case from a no content response
                if let response = response.response,
                    let statusCode = HttpStatusCode(rawValue: response.statusCode),
                    statusCode.isSuccess {
                    onSuccess(NetworkResponse())
                } else {
                    if response.result.error?._code == NSURLErrorTimedOut {
                        var timeOutErrorResponse = NetworkError()
                        timeOutErrorResponse.statusCode = NSURLErrorTimedOut
                        onError(timeOutErrorResponse)
                        print("ERROR: Time out error")
                    } else if response.result.error?._code == NSURLErrorCannotFindHost {
                        print("HOST NOT FOUND!")
                        var noHostResponse = NetworkError()
                        noHostResponse.statusCode = NSURLErrorCannotFindHost
                        onError(noHostResponse)
                    } else if response.result.error?._code == NSURLErrorNotConnectedToInternet {
                        print("NO INTERNET CONNECTION")
                        var noInternetResponse = NetworkError()
                        noInternetResponse.statusCode = NSURLErrorNotConnectedToInternet
                        onError(noInternetResponse)
                    } else {
                        let errorResponse = NetworkError(response: response)
                        onError (errorResponse)
                        print("ERROR: \(errorResponse.detailedError())")
                    }
                }
            }
        }
    }

    internal func requestData(_ url: URLRequest, onSuccess: @escaping (NetworkResponse) -> Void, onError: @escaping (NetworkError) -> Void) {

        sessionManager?.request(url).validate().responseData(completionHandler: { response in
            switch response.result {
                case .success(let data):
                    if let unwrappedString = String(data: data, encoding: .utf8) {
                        onSuccess(NetworkResponse(status: 200, data: NSString(string: unwrappedString)))
                    } else {
                        var error = NetworkError()
                        error.errorMessage = "Could not decode String"
                        onError(error)
                }
                case .failure:
                    onError(NetworkError())
            }
        })
    }

    func uploadImage(_ service: Service, image: Data, onSuccess: @escaping (NetworkResponse) -> Void, onError: @escaping (NetworkError) -> Void) {
        guard let service = service as? URLRequestConvertible else { return }
        sessionManager?.upload(multipartFormData: { (multiPartFormData) in
            multiPartFormData.append(image, withName: "image", fileName: "file.jpg", mimeType: "image/jpg")
        }, with: service, encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.validate(statusCode: 200..<300).responseJSON { response in
                    switch response.result {
                    case .success:
                        onSuccess(NetworkResponse(response: response))
                    case .failure:
                        onError(NetworkError(response: response))
                    }
                }
            case .failure(let error):
                print(error)
                onError(NetworkError())
            }
        })
    }
    
    func requestAndDecrypt(_ service: Service, onSuccess: @escaping (JSON) -> Void, onError: @escaping (NetworkError) -> Void) {
        self.request(service, onSuccess: { (networkResponse) in
            do {
                let encryptedModel = try GCMResponseModel.create(from: networkResponse.body!)
                if let decryptedJSON = APISecurityManager.sharedInstance.gcmDecrypt(content: encryptedModel.content, tag: encryptedModel.tag, iv: encryptedModel.iv) {
                    onSuccess(JSON.init(parseJSON: decryptedJSON))
                } else {
                    onError(NetworkError(status: 500, error: "JSON Parsed Failed", data: nil))
                }
            } catch {
                onError(NetworkError(status: 500, error: "Decryption Failed", data: nil))
            }
        }) { (networkError) in
            onError(networkError)
        }
    }
    
    mutating func activateContingency() {
        self.isInContingency = true
    }

    func getBaseURL() -> String {
        
        if isInContingency {
            return self.getContingencyURL()
        }
        
        #if DEBUG
            return "https://api-dev.soymach.com"
        #elseif STAGING
            return "https://api-staging.soymach.com"
        #elseif AUTOMATION
            return "https://api-automation.soymach.com"
        #else //Release
            return "https://api.soymach.com"
        #endif
    }
    
    func getContingencyURL() -> String {
        #if DEBUG
        return "https://api-nw.soymach.com"
        #elseif STAGING
            return "https://api-staging.soymach.com"
        #elseif AUTOMATION
            return "https://api-automation.soymach.com"
        #else //Release
            return "https://mach.bci.cl"
        #endif
    }
    
    func deleteTokens() {
        authTokenManager.deleteAccessToken()
        authTokenManager.deleteRefreshToken()
    }

    func getSessionId() -> String? {
        let accessToken = authTokenManager.getAccessToken()
        guard let accessTokenPayload = accessToken.split(".").get(at: 1) else {
            return nil
        }
        guard let bodyData = AlamofireNetworkLayer.base64UrlDecode(accessTokenPayload) else {
            return nil
        }
        guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
            return nil
        }
        guard let sessionId = payload["sessionId"] as? String else {
            return nil
        }
        return sessionId
    }

    private static func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }

}
