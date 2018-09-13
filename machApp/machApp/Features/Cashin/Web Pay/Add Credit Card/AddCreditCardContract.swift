//
//  AddCreditCardContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/8/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol AddCreditCardViewProtocol: BaseViewProtocol {
    func updateBalance(balance: String)
    func displayWebView(with webpayURLResponse: WebPayURLResponse)
}

protocol AddCreditCardPresenterProtocol: BasePresenterProtocol {
    func getBalance()
    func setView(view: AddCreditCardViewProtocol)
    func getURLForWebView()
}

protocol AddCreditCardRepositoryProtocol {
    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getSavedBalance(response: (Balance?) -> Void)
    func fetchWebPayURL(onSuccess: @escaping (WebPayURLResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

// se usa en el presenter
enum AddCreditCardError: Error {
    case failed(message: String)
}

class AddCreditCardErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
