//
//  SelectAmountRepository.swift
//  machApp
//
//  Created by lukas burns on 3/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class SelectAmountRepository: SelectAmountRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: SelectAmountErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: SelectAmountErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            apiService?.request(AccountService.balance(), onSuccess: { (networkResponse) in
                do {
                    // swiftlint:disable:next force_unwrapping
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
