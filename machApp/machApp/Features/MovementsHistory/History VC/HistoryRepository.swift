//
//  HistoryRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/2/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class HistoryRepository: HistoryRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: ErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: ErrorParser?) {
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
                    //swiftlint:disable:next force_unwrapping
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (errorResponse) in
                //swiftlint:disable:next force_unwrapping
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        }
    }

    func getSavedBalance(response: (Balance?) -> Void) {
        response(BalanceManager.sharedInstance.getBalance())
    }
}
