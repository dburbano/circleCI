//
//  WithdrawTEFSavedAccountPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 4/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class WithdrawTEFSavedAccountPresenter: WithdrawTEFSavedAccountPresenterProtocol {
    
    let minimumWithdrawAmount: Int = 2000
    let maximumAmount: Int = 500000
    
    weak var view: WithdrawTEFSavedAccountViewProtocol?
    var repository: WithdrawTEFSavedAccountRepositoryProtocol?
    var balance: Int?
    var amount: Int?
    var accountNumber: String?
    var bank: Bank?
    
    required init(repository: WithdrawTEFSavedAccountRepositoryProtocol?) {
        self.repository = repository
    }
    
    func getBalance() {
        repository?.getSavedBalance(response: {[weak self] (balance) in
            if let unwrappedBalance = balance, let unwrappedSelf = self {
                unwrappedSelf.balance = Int(unwrappedBalance.balance)
                unwrappedSelf.view?.updateBalance(balance: Int(unwrappedBalance.balance))
            }
        })
        self.repository?.getBalance(onSuccess: { (balanceRessponse) in
            self.balance = Int(balanceRessponse.balance)
            self.view?.updateBalance(balance: Int(balanceRessponse.balance))
        }, onFailure: { (balanceError) in
            self.handle(error: balanceError)
        })
    }
    
    func setAccountInfo(with withdrawData: WithdrawData?) {
        guard let withdrawData = withdrawData else {
            /* If by any means we get here and bankData if null we need to do 2 things:
             1. Delete all the user data related to withdraw
             2. Navigate back to withdrawTEFViewController so the user can save the data again */
            deleteWithdrawData()
            view?.navigateToWithdrawTEF()
            return
        }
        bank = withdrawData.bank
        accountNumber = withdrawData.accountNumber
    }
    
    func getCashoutViewModel() -> CashoutViewModel? {
        guard let amount = amount,
            let accountNumber = accountNumber,
            let bank = bank,
            let user = AccountManager.sharedInstance.getUser()  else {
                return nil
        }
        let cashoutViewModel = CashoutViewModel(userViewModel: UserViewModel(user: user), amount: amount, accountNumber: accountNumber, bank: bank)
        return cashoutViewModel
    }
    
    func deleteSavedAccount() {
        AccountManager.sharedInstance.deleteCashoutBank()
        AccountManager.sharedInstance.deleteCashoutAccount()
        view?.didDeleteSavedAccount()
    }
    
    func setupBankData() {
        guard let bank = bank,
            let accountNumber = accountNumber else { return }
        view?.presentBankData(with: bank, accountNumber: "Nº de cuenta: \(accountNumber)")
    }
    
    func amountEdited(amount: Int?) {
        if let amount = amount {
            self.amount = amount
            if let balance = balance {
                
                
                if amount >= minimumWithdrawAmount && amount <= balance {
                    //Success case
                    view?.presentAmountError(with: "Debes retirar mínimo \(minimumWithdrawAmount.toCurrency())", textColor: Color.greyishBrown, textfieldFlag: false, continueButtonFlag: true)
                } else if amount < minimumWithdrawAmount {
                    // Less than the minimum ammount case
                    view?.presentAmountError(with: "Debes retirar mínimo \(minimumWithdrawAmount.toCurrency())", textColor: Color.greyishBrown, textfieldFlag: false, continueButtonFlag: false)
                } else if amount > maximumAmount {
                    //More than the maximum ammount case
                    view?.presentAmountError(with: "Sólo puedes retirar \(maximumAmount.toCurrency())", textColor: Color.redOrange, textfieldFlag: true, continueButtonFlag: false)
                } else {
                    //More than the available balance case
                    view?.presentAmountError(with: "Sólo puedes retirar \(balance.toCurrency())", textColor: Color.redOrange, textfieldFlag: true, continueButtonFlag: false)
                }
            }
            view?.updateAmount(with: amount.toCurrency())
        }
    }
    
    func confirmCashout() {
        view?.presentPasscode(onSuccess: passcodeSucceeded, onFailure: passcodeFailed)
    }
    
    func didConfirmAccountDeletion() {
        view?.navigateToWithdrawTEF()
    }
    
    //swiftlint:disable:next cyclomatic_complexity
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError:
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let withdrawError):
            guard let withdrawError = withdrawError as? WithdrawTEFSavedAccountError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch withdrawError {
            case .balance:
                break
            case .bank:
                break
            case .cashout:
                break
            }
        case .clientError(let withdrawError):
            guard let withdrawError = withdrawError as? WithdrawTEFSavedAccountError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch withdrawError {
            case .balance:
                break
            case .bank:
                break
            case .cashout:
                break
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
    
    private func passcodeSucceeded() {
        view?.passcodeSuccesfull()
    }
    
    private func passcodeFailed() {}
    
    
    private func deleteWithdrawData() {
        AccountManager.sharedInstance.deleteCashoutBank()
        AccountManager.sharedInstance.deleteCashoutBankName()
        AccountManager.sharedInstance.deleteCashoutAccount()
    }
}
