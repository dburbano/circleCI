//
//  WithdrawATMPresenter.swift
//  machApp
//
//  Created by Lukas Burns on 12/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class WithdrawATMPresenter: WithdrawATMPresenterProtocol {

    let amounts = [5000, 10000, 20000, 40000, 60000, 80000, 100000]

    var selectedAmount: Int?
    var balance: Int?

    var view: WithdrawATMViewProtocol?
    var repository: WithdrawATMRepositoryProtocol?

    required init(repository: WithdrawATMRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: WithdrawATMViewProtocol) {
        self.view = view
    }

    func initialSetup() {
        self.getBalanceAndUpdate()
    }

    private func getBalanceAndUpdate() {
        if let balance = BalanceManager.sharedInstance.getBalance()?.balance {
            self.view?.updateBalance(balance: Int(balance))
            self.balance = Int(balance)
        }
        self.repository?.getBalance(onSuccess: { (balanceResponse) in
            self.view?.updateBalance(balance: Int(balanceResponse.balance))
            self.balance = Int(balanceResponse.balance)
        }, onFailure: { (error) in
            self.handle(error: error)
        })
    }

    func getAmount(at index: IndexPath) -> Int? {
        return amounts.get(at: index.row)
    }

    func getSelectedAmount() -> Int? {
        return self.selectedAmount
    }

    func getNumberOfAmountOptions() -> Int {
        return amounts.count
    }

    func getBalance() -> Int {
        return self.balance!
    }

    func cashoutATMAccepted() {
        // Show PIN
        self.view?.presentPasscode(onPINSuccessful: pinSucceeded, onPinFailure: pinFailed)
    }

    private func pinSucceeded() {
        // Navigate to executeTransaction and implement new cashout logic there
        self.view?.navigateToExecuteCashout(with: CashoutATMViewModel(amount: selectedAmount ?? 0))
    }

    private func pinFailed() {
        // Record Analytic
    }

    func amountSelected(at indexPath: IndexPath) {
        self.selectedAmount = amounts.get(at: indexPath.row)
        self.view?.showConfirmationDialog()
    }

    //swiftlint:disable:next
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let withdrawError):
            guard let withdrawError = withdrawError as? WithdrawATMError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch withdrawError {
            case .balance:
                break
            }
        case .clientError(let withdrawError):
            guard let withdrawError = withdrawError as? WithdrawATMError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch withdrawError {
            case .balance:
                break
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
}
