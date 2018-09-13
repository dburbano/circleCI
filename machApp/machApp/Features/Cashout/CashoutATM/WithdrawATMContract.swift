//
//  WithdrawATMContract.swift
//  machApp
//
//  Created by Lukas Burns on 12/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
    
protocol WithdrawATMViewProtocol: BaseViewProtocol {
    
    func showConfirmationDialog()
    
    func updateBalance(balance: Int)
    
    func presentPasscode(onPINSuccessful: @escaping() -> Void, onPinFailure: @escaping() -> Void)
    
    func navigateToExecuteCashout(with cashoutATMViewModel: CashoutATMViewModel)
}

protocol WithdrawATMPresenterProtocol: BasePresenterProtocol {
    
    func setView(view: WithdrawATMViewProtocol)
    
    func initialSetup()
    
    func getAmount(at index: IndexPath) -> Int?
    
    func getNumberOfAmountOptions() -> Int
    
    func cashoutATMAccepted()
    
    func amountSelected(at indexPath: IndexPath)
    
    func getSelectedAmount() -> Int?

    func getBalance() -> Int
}

protocol WithdrawATMRepositoryProtocol {
    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum WithdrawATMError: Error {
    case balance(message: String)
}

class WithdrawATMErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
