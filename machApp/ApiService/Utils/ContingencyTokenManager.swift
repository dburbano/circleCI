//
//  ContingencyTokenManager.swift
//  machApp
//
//  Created by Lukas Burns on 7/11/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import KeychainSwift
import Alamofire

class ContingencyTokenManager: AuthTokenManagerProtocol {
    
    static let sharedInstance: ContingencyTokenManager = {
        let instance = ContingencyTokenManager()
        return instance
    }()
    
    let keychain = KeychainSwift()

    let contingencyTokenKey = "CONTINGENCY_TOKEN"
    let contingencyRefreshTokenKey = "CONTINGENCY_REFRESH_TOKEN"
    let contingencyAccessTokenKey = "CONTINGENCY_ACCESS_TOKEN"

    func set(contingencyToken: String) {
        keychain.set(contingencyToken, forKey: contingencyTokenKey, withAccess: .accessibleAlways)
    }
    
    func set(accessToken: String) {
        keychain.set(accessToken, forKey: contingencyAccessTokenKey, withAccess: .accessibleAlways)
    }
    
    func set(refreshToken: String) {
        keychain.set(refreshToken, forKey: contingencyRefreshTokenKey, withAccess: .accessibleAlways)
    }
    
    func getContingencyToken() -> String? {
        return keychain.get(contingencyTokenKey) 
    }
    
    func getAccessToken() -> String {
        if let contingencyAccessToken = keychain.get(contingencyAccessTokenKey) {
            return contingencyAccessToken
        }
        return ""
    }
    
    func getRefreshToken() -> String {
        if let contingencyRefreshToken = keychain.get(contingencyRefreshTokenKey) {
            return contingencyRefreshToken
        }
        return ""
    }
    
    func deleteContingencyToken() {
        keychain.delete(contingencyTokenKey)
    }
    
    func deleteAccessToken() {
        keychain.delete(contingencyAccessTokenKey)
    }
    
    func deleteRefreshToken() {
        keychain.delete(contingencyRefreshTokenKey)
    }
}
