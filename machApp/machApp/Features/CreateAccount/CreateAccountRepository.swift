//
//  CreateAccountRepository.swift
//  machApp
//
//  Created by Lukas Burns on 5/25/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class CreateAccountRepository: CreateAccountRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: CreateAccountErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: CreateAccountErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }
    
    internal func createAccount(onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void) {
        self.apiService?.request(AccountService.create(), onSuccess: { (networkResponse) in
            // Account Created
            onSuccess()
        }, onError: { (error) in
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(networkError: error))!)
        })
    }
}
