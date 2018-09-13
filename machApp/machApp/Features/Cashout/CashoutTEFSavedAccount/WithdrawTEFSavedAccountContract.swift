//
//  WithdrawTEFSavedAccountContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 4/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol WithdrawTEFSavedAccountViewProtocol: BaseViewProtocol {
    func showBalanceError()
    func hideBalanceError()
    func updateBalance(balance: Int)
    func updateAmount(with string: String)
    func presentAmountError(with text: String, textColor: UIColor, textfieldFlag: Bool, continueButtonFlag: Bool)
    func presentPasscode(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void)
    func passcodeSuccesfull()
    func didDeleteSavedAccount()
    func presentBankData(with bank: Bank, accountNumber: String)
    func navigateToWithdrawTEF()
}

protocol WithdrawTEFSavedAccountPresenterProtocol: BasePresenterProtocol {
    var view: WithdrawTEFSavedAccountViewProtocol? { get set }
    var accountNumber: String? { get }
    var bank: Bank? { get }
    func getBalance()
    func amountEdited(amount: Int?)
    func confirmCashout()
    func setAccountInfo(with withdrawData: WithdrawData?)
    func getCashoutViewModel() -> CashoutViewModel?
    func deleteSavedAccount()
    func setupBankData()
    func didConfirmAccountDeletion()
}

enum WithdrawTEFSavedAccountError: Error {
    case balance(message: String)
    case bank(message: String)
    case cashout(message: String)
}

protocol WithdrawTEFSavedAccountRepositoryProtocol {
    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getSavedBalance(response: (Balance?) -> Void)
}

class WithdrawTEFSavedAccountErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
