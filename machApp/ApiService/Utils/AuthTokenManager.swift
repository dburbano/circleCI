//
//  AuthTokenHelper.swift
//  machApp
//
//  Created by lukas burns on 2/20/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import KeychainSwift
import Alamofire

class AuthTokenManager: AuthTokenManagerProtocol {

    static let sharedInstance: AuthTokenManager = {
        let instance = AuthTokenManager()
        return instance
    }()

    let keychain = KeychainSwift()
    
    let accessTokenKey = "ACCESS_TOKEN"
    let refreshTokenKey = "REFRESH_TOKEN"

    func set(accessToken: String) {
        keychain.set(accessToken, forKey: accessTokenKey, withAccess: .accessibleAlways)
    }

    func set(refreshToken: String) {
        keychain.set(refreshToken, forKey: refreshTokenKey, withAccess: .accessibleAlways)
    }

    func getAccessToken() -> String {
        if let authToken = keychain.get(accessTokenKey) {
            return authToken
        }
        return ""
    }

    func getRefreshToken() -> String {
        if let refreshToken = keychain.get(refreshTokenKey) {
            return refreshToken
        }
        return ""
    }

    func deleteAccessToken() {
        keychain.delete(accessTokenKey)
    }

    func deleteRefreshToken() {
        keychain.delete(refreshTokenKey)
    }
}
