//
//  WithdrawATMDetailContract.swift
//  machApp
//
//  Created by Lukas Burns on 1/2/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol WithdrawATMDetailViewProtocol: BaseViewProtocol {
    func setDisabledDetailArea(expired: Bool)
    func updateBalance(balance: Int)
    func setCodeLabel(code: String)
    func setAmountLabel(amount: Int)
    func setExpiredAtLabel(expiredAt: String)
    func goToWithdrawMenu()
    func goToRemovedConfirmMessage()
    func goToCashoutATMCreatedDialogue()
}

protocol WithdrawATMDetailPresenterProtocol: BasePresenterProtocol {
    func setView(view: WithdrawATMDetailViewProtocol)
    func initialSetup(_ cashoutATMResponse: CashoutATMResponse?)
    func getPin() -> String
    func showDialogueWhenWithdrawWasCreated()
}

protocol WithdrawATMDetailRepositoryProtocol {
    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func removeCurrentCashoutATM(with cashOutAtmId: String, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum WithdrawATMDetailError: Error {
    case balance(message: String)
}

class WithdrawATMDetailErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
    
}
