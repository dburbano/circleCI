//
//  WithdrawContract.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/18/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

protocol WithdrawTEFViewProtocol: BaseViewProtocol {
    func navigateBackToMore()
    func enableButton()
    func disableButton()
    func showAccountError()
    func hideAccountError()
    func showAmountError(withMessage message: String)
    func keepAmountNormalColor()
    func hideAmountError()
    func showCashoutError()
    func showBalanceError()
    func hideBalanceError()
    func cleanBankLabel()
    func cleanAccountLabel()
    func cleanAmountLabel()
    func updateBalance(balance: Int)
    func setBankTexField(bankName: String)
    func reloadBanks()
    func setSelectedBank(at index: Int)
    func presentPasscode(onSuccess: @escaping() -> Void, onFailure: @escaping() -> Void)
    func navigateToExecuteTransaction()
    func setUserName(userName: String)
    func setRut(rut: String?)
    func setAccountNumber(accountNumber: String)
    func setAmount(with text: String)
    func showNameAndRutCannotBeEditedToast()
    func showAccountNumberError(with flag: Bool)
}

protocol WithdrawTEFPresenterProtocol: BasePresenterProtocol {
    func setView(view: WithdrawTEFViewProtocol)
    func viewDidLoad()
    func setUserInfo()
    func navigateBack()
    func enable()
    func disable()
    func accountEdited(_ text: String?)
    func accountEndEdited(_ text: String?)
    func getBalance()
    func bankSelected(at row: Int)
    func getBankName(at row: Int) -> String
    func getNumberOfBanks() -> Int
    func confirmCashout()
    func amountEdited(amount: Int?)
    func amountEndEdited(amount: Int?)
    func getCashoutViewModel() -> CashoutViewModel?
    func didTapHiddenButton()
    func presentAccountNumberError()
}

protocol WithdrawTEFRepositoryProtocol {
    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getBanks(onSuccess: @escaping ([Bank]) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getSavedBalance(response: (Balance?) -> Void)
}

enum WithdrawTEFError: Error {
    case balance(message: String)
    case bank(message: String)
    case cashout(message: String)
}

class WithdrawTEFErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
