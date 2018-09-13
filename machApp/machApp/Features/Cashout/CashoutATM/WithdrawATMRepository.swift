//
//  WithdrawATMRepository.swift
//  machApp
//
//  Created by Lukas Burns on 12/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class WithdrawATMRepository: WithdrawATMRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: WithdrawATMErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: WithdrawATMErrorParser?) {
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
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (errorResponse) in
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        }
    }
}
