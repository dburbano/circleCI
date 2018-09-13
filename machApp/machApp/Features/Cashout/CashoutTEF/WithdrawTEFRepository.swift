//
//  WithdrawRepository.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/18/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class WithdrawTEFRepository: WithdrawTEFRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: WithdrawTEFErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: WithdrawTEFErrorParser?) {
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

    internal func getBanks(onSuccess: @escaping ([Bank]) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            apiService?.request(CashService.banks, onSuccess: { (networkResponse) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let banks = try Bank.createArray(from: networkResponse.body!)
                    onSuccess(banks)
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
