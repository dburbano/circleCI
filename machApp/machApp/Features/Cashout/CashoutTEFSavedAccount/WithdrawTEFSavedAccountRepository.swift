//
//  WithdrawTEFSavedAccountRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 4/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class WithdrawTEFSavedAccountRepository: WithdrawTEFSavedAccountRepositoryProtocol {
    
    var apiService: APIServiceProtocol?
    var errorParser: WithdrawTEFSavedAccountErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: WithdrawTEFSavedAccountErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }
    
    internal func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            apiService?.request(AccountService.balance(), onSuccess: { (networkResponse) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let balanceResponse = try BalanceResponse.create(from: networkResponse.body!)
                    BalanceManager.sharedInstance.save(balance: Balance(balanceResponse: balanceResponse))
                    onSuccess(balanceResponse)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (errorResponse) in
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        }
    }
    
    func getSavedBalance(response: (Balance?) -> Void) {
        response(BalanceManager.sharedInstance.getBalance())
    }
    
}
