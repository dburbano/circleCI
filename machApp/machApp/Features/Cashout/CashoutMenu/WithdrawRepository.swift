//
//  WithdrawRepository.swift
//  machApp
//
//  Created by Lukas Burns on 1/2/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class WithdrawRepository: WithdrawRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: WithdrawErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: WithdrawErrorParser?) {
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

    internal func getWithdrawATMDetail(onSuccess: @escaping (CashoutATMResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            apiService?.requestAndDecrypt(CashService.getCashoutATM, onSuccess: { (jsonResponse) in
                do {
                    let cashoutResponse = try CashoutATMResponse.create(from: jsonResponse)
                    // TODO: update 
                    onSuccess(cashoutResponse)
                } catch {
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (errorResponse) in
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        }
    }
}
