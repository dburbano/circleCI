//
//  WithdrawATMDetailRepository.swift
//  machApp
//
//  Created by Lukas Burns on 1/2/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class WithdrawATMDetailRepository: WithdrawATMDetailRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: WithdrawATMDetailErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: WithdrawATMDetailErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }
    
    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
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

    func removeCurrentCashoutATM(with cashOutAtmId: String, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            apiService?.request(CashService.deleteCashoutATM(id: cashOutAtmId), onSuccess: { _ in
                    onSuccess()
                }, onError: { (errorResponse) in
                    onFailure((self.errorParser?.getError(networkError: errorResponse))!)
                }
            )
        }
    }
}
