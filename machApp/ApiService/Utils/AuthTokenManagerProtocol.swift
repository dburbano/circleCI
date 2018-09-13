//
//  AuthTokenProtocol.swift
//  machApp
//
//  Created by Lukas Burns on 7/11/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol AuthTokenManagerProtocol {
    func set(accessToken: String)
    
    func set(refreshToken: String)
    
    func getAccessToken() -> String
    
    func getRefreshToken() -> String

    func deleteAccessToken()
    
    func deleteRefreshToken()
    
}
