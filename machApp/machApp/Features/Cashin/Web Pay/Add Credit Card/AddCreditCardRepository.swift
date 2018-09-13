//
//  AddCreditCardRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/8/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class AddCreditCardRepository: AddCreditCardRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: AddCreditCardErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: AddCreditCardErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            apiService?.request(AccountService.balance(), onSuccess: {[weak self] (networkResponse) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let balanceResponse = try BalanceResponse.create(from: networkResponse.body!)
                    BalanceManager.sharedInstance.save(balance: Balance(balanceResponse: balanceResponse))
                    onSuccess(balanceResponse)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    //swiftlint:disable:next force_unwrapping
                    onFailure((self?.errorParser?.getError(error: error))!)
                }
            }, onError: {[weak self] (errorResponse) in
                //swiftlint:disable:next force_unwrapping
                onFailure((self?.errorParser?.getError(networkError: errorResponse))!)
            })
        }
    }

    func getSavedBalance(response: (Balance?) -> Void) {
        response(BalanceManager.sharedInstance.getBalance())
    }

    func fetchWebPayURL(onSuccess: @escaping (WebPayURLResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {

        apiService?.request(CashService.inscribeCreditCardWebPay, onSuccess: {[weak self] response in
            do {
                //swiftlint:disable:next force_unwrapping
                let webpayResponse = try WebPayURLResponse.create(from: response.body!)
                onSuccess(webpayResponse)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                //swiftlint:disable:next force_unwrapping
                onFailure((self?.errorParser?.getError(error: error))!)
            }
            }, onError: {[weak self] errorResponse in
                //swiftlint:disable:next force_unwrapping
                onFailure((self?.errorParser?.getError(networkError: errorResponse))!)
        })
    }
}
