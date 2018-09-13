//
//  RechargeRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/9/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol RechargeViewProtocol: BaseViewProtocol {
    func updateBalance(balance: Int)
    func didDeleteCreditCard()
    func updateCreditCardImage(with imageName: String)
    func updateCreditCardLabel(with response: String)
    func updateAmount(with string: String)
    func presentAmountError(with response: RechargePresenterResponse)
    func presentPasscode(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void)
    func passcodeSuccesfull()
}

protocol RechargePresenterProtocol: BasePresenterProtocol {

    var creditCardResponse: CreditCardResponse? { get set }
    var balance: Int? { get set }
    func getBalance()
    func setView(view: RechargeViewProtocol)
    func deleteCreditCard()
    func getCreditCardImageName(with name: String)
    func setCreditCardLabel(with creditCard: CreditCardResponse)
    func amountEdited(amount: Int?)
    func rechargeAccount(with amount: String)
}

enum RechargeError: Error {
    case failed(message: String)
}

class RechargeErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}

protocol RechargeRepositoryProtocol {
    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getSavedBalance(response: (Balance?) -> Void)
    func deleteCreditCard(with token: String, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum RechargePresenterResponse {
    case normal(message: String)
    case overUpperBoundAmmount(message: String)
    case withdraw(message: String)
}
