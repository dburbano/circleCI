//
//  OAuth2Handler.swift
//  machApp
//
//  Created by lukas burns on 8/29/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class OAuth2Handler: RequestAdapter, RequestRetrier {
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void

    internal let apiVersion = "0.14.0"

    internal let sessionManager: SessionManager = {

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

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }()

    private let lock = NSLock()

    private var baseURLString: String
    private var accessToken: String
    private var refreshToken: String

    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    private var authTokenManager: AuthTokenManagerProtocol

    public init(baseURLString: String, authTokenManager: AuthTokenManagerProtocol) {
        self.authTokenManager = authTokenManager
        self.baseURLString = baseURLString
        self.accessToken = authTokenManager.getAccessToken()
        self.refreshToken = authTokenManager.getRefreshToken()
    }
    
    func saveTokens(response: DataResponse<Any>) {
        if let json = response.result.value as? [String: Any] {
            if let accessToken = json["access_token"] as? String {
                authTokenManager.set(accessToken: accessToken)
            }
            if let refreshToken = json["refresh_token"] as? String {
                authTokenManager.set(refreshToken: refreshToken)
            }
        }
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        self.accessToken = authTokenManager.getAccessToken()
        self.refreshToken = authTokenManager.getRefreshToken()
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseURLString) {
            var urlRequest = urlRequest
            urlRequest.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
            urlRequest.setValue(apiVersion, forHTTPHeaderField: "Accept-Version")
            return urlRequest
        }
        return urlRequest
    }

    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == HttpStatusCode.Http401_Unauthorized.rawValue {
            if refreshToken.isEmpty {
                completion(false, 0.0)
            }

            requestsToRetry.append(completion)

            if !isRefreshing {
                refreshTokens(completion: { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }

                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }

                    if let accessToken = accessToken {
                        strongSelf.accessToken = accessToken
                        self?.authTokenManager.set(accessToken: accessToken)
                    }
                    if let refreshToken = refreshToken {
                        strongSelf.refreshToken = refreshToken
                        self?.authTokenManager.set(refreshToken: refreshToken)
                    }

                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }, lastAccessToken: request.request?.allHTTPHeaderFields?["Authorization"]?.split(" ").last ?? "")
            }
        } else {
            completion(false, 0.0)
        }
    }

    private func refreshTokens(completion: @escaping RefreshCompletion, lastAccessToken: String) {

        if self.accessToken != lastAccessToken { return }

        guard !isRefreshing else { return }

        isRefreshing = true

        let refreshToken = self.refreshToken

        let parameters: [String: Any] = ["refresh_token": refreshToken]

        print("Calling Refresh Token with token: \(refreshToken) for object")
        print(Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque())

        sessionManager.request(AuthorizationService.refreshToken(parameters: parameters)).validate().responseJSON { [weak self](response) in
            guard let strongSelf = self else { return }

            switch response.result {
            case .success:
                if let json = response.result.value as? [String: Any],
                    let accessToken = json["access_token"] as? String,
                    let refreshToken = json["refresh_token"] as? String {
                    completion(true, accessToken, refreshToken)
                } else {
                    completion(false, nil, nil)
                }
            case .failure:
                guard response.response?.statusCode == HttpStatusCode.Http401_Unauthorized.rawValue else {
                    strongSelf.isRefreshing = false
                    return
                }
                completion(false, nil, nil)
            }
            strongSelf.isRefreshing = false
        }
    }
}
