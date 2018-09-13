//
//  CashInRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 10/24/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class CashInRepository: CashInRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: CashInErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: CashInErrorParser?) {
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
                    ExceptionManager.sharedInstance.recordError(error)
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

    func getCreditCard(onSuccess: @escaping (CreditCardResponse?) -> Void, onFailure: @escaping (ApiError) -> Void) {
        //Verify if the credit card is saved
        if let creditCard = CreditCardManager.sharedInstance.isThereACreditCardSaved() {
            onSuccess(creditCard)
        }
            //Verify is the user has a credit card but is recovering his account
        else {
            apiService?.request(CashService.getCreditCards, onSuccess: { (response) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let responseArray = response.body!.arrayValue

                    /*
                     If the user does not have a credit card, return nil.
                     Otherwise, save the credit card and return it
                     */
                    if responseArray.isEmpty {
                        onSuccess(.none)
                    } else {
                        for element in responseArray {
                            let creditCard = try CreditCardResponse.create(from: element)
                            //Save the credit card
                            CreditCardManager.sharedInstance.set(creditCard: creditCard)
                            onSuccess(creditCard)
                        }
                    }
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    //swiftlint:disable:next force_unwrapping
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { [weak self] errorResponse in
                //swiftlint:disable:next force_unwrapping
                onFailure((self?.errorParser?.getError(networkError: errorResponse))!)
            })
        }
    }
    
    private func saveUserAccountInformation(with accountResponse: AccountInformationResponse) {
        AccountManager.sharedInstance.set(rut: accountResponse.rut)
        AccountManager.sharedInstance.set(cashinBank: accountResponse.bank)
        AccountManager.sharedInstance.set(cashinAccountNumber: accountResponse.accountNumber)
        AccountManager.sharedInstance.set(cashinAccountType: accountResponse.accountType)
    }
    
    private func getUserAccountInformation() -> AccountInformationResponse? {
        guard let user = AccountManager.sharedInstance.getUser(),
            let firstName = user.firstName,
            let lastName = user.lastName,
            let rut = AccountManager.sharedInstance.getRut(),
            let bank = AccountManager.sharedInstance.getCashinBank(),
            let accountNumber = AccountManager.sharedInstance.getCashinAccountNumber(),
            let accountType = AccountManager.sharedInstance.getCashinAccountType()
            else {
                return nil
        }
        return AccountInformationResponse(fullName: firstName + " " + lastName, rut: rut, bank: bank, accountNumber: accountNumber, accountType: accountType)
    }
    
    internal func getAccountInformation(onSuccess: @escaping (AccountInformationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            apiService?.request(AccountService.information(), onSuccess: {[weak self] (networkResponse) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let accountInfoResponse = try AccountInformationResponse.create(from: networkResponse.body!)
                    //Save received response
                    self?.saveUserAccountInformation(with: accountInfoResponse)
                    onSuccess(accountInfoResponse)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    //swiftlint:disable:next force_unwrapping
                    onFailure((self?.errorParser?.getError(error: error))!)
                }
                }, onError: { (errorResponse) in
                    //swiftlint:disable:next force_unwrapping
                    onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        }
    }
}
