//
//  WithdrawContract.swift
//  machApp
//
//  Created by Lukas Burns on 12/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol WithdrawViewProtocol: BaseViewProtocol {
    func navigateToWithdrawTEF()
    func navigateToWithdrawTEFSavedAccount(with withdrawData: WithdrawData)
    func navigateToWithdrawATM()
    func navigateToWithdrawATMDetail(cashoutATMResponse: CashoutATMResponse)
    func updateBalance(balance: Int)
    func setActiveWithdrawATMButton()
    func setLoadingWithdrawATMButton() 
    func changeTitle(to text: String)
    func hideBackButton()
    func showBackButton()
    func showContingencyInformation()
    func navigateToStartAuthenticationProcess()
    func dismissAuthenticationProcess()
}

protocol WithdrawPresenterProtocol: BasePresenterProtocol, AuthenticationDelegate {
    func setView(view: WithdrawViewProtocol)
    func initialSetup()
    func withdrawTEFSelected()
    func withdrawATMSelected()
}

protocol WithdrawRepositoryProtocol {
    func getBalance(
        onSuccess: @escaping (BalanceResponse) -> Void,
        onFailure: @escaping (ApiError) -> Void
    )
    func getWithdrawATMDetail(
        onSuccess: @escaping (CashoutATMResponse) -> Void,
        onFailure: @escaping (ApiError) -> Void
    )
}

enum WithdrawError: Error {
    case balance(message: String)
    case cashoutATMNotFound(message: String)
    case userVerificationNeeded(message: String)
    case atmDailyAmountLimitExceeded(message: String)
}

class WithdrawErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == Constants.ApiError.CashoutATM.getNotFoundError {
            return ApiError.clientError(error: WithdrawError.cashoutATMNotFound(message: ""))
        } else if networkError.errorType == Constants.ApiError.CashoutATM.userVerifitacionNeeded {
            return ApiError.clientError(error: WithdrawError.userVerificationNeeded(message: ""))
        } else if networkError.errorType == Constants.ApiError.CashoutATM.atmDailyAmountLimit {
            return ApiError.clientError(error: WithdrawError.atmDailyAmountLimitExceeded(message: ""))
        }
        return super.getError(networkError: networkError)
    }
}
