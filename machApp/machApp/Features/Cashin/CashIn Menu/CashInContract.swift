//
//  CashInContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 10/24/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol CashInViewProtocol: BaseViewProtocol {
    func updateBalance(balance: String)
    func thereIsA(creditCard: CreditCardResponse)
    func thereIsNotACreditCard()
    func navigateToCashInDetailWith(accountInfo: AccountInformationResponse)
    func setTefButtonAsLoading()
    func setTefButtonAsActive()
    func navigateToStartAuthenticationProcess()
    func dismissAuthenticationProcess()
    func closeAuthenticationProcess()
}

protocol CashInPresenterProtocol: BasePresenterProtocol, AuthenticationDelegate {
    func getBalance()
    func setView(view: CashInViewProtocol)
    func getCreditCard()
    func getAccountInformation()
    func viewDidLoad()
}

protocol CashInRepositoryProtocol {
    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getSavedBalance(response: (Balance?) -> Void)
    func getCreditCard(onSuccess: @escaping (CreditCardResponse?) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getAccountInformation(onSuccess: @escaping (AccountInformationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}
