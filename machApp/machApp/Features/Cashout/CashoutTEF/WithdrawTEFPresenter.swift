//
//  WithdrawPresenter.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/18/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class WithdrawTEFPresenter: WithdrawTEFPresenterProtocol {

    weak var view: WithdrawTEFViewProtocol?
    var repository: WithdrawTEFRepositoryProtocol?

    let minAmount: Int = 2000
    let maxAmount: Int = 500000
    let minValueToValidateAmount: Int = 1000

    var amount: Int?
    var selectedBank: Bank?
    var banks: [Bank] = []
    var account: String?
    var balance: Int = 0

    required init(repository: WithdrawTEFRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: WithdrawTEFViewProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        self.getBanks()
    }

    func setUserInfo() {
        let firstName = AccountManager.sharedInstance.getUserFirstName()
        let lastName = AccountManager.sharedInstance.getUserLastName()
        self.view?.setUserName(userName: firstName + " " + lastName)
        if let rut = AccountManager.sharedInstance.getRut() {
            self.view?.setRut(rut: rut)
        }
        if let accountNumber = AccountManager.sharedInstance.getCashoutAccountNumber() {
            self.account = accountNumber
            self.view?.setAccountNumber(accountNumber: accountNumber)
        }
    }

    func navigateBack() {
        self.view?.navigateBackToMore()
    }

    func enable() {
        self.view?.enableButton()
    }

    func disable() {
        self.view?.disableButton()
    }

    func accountEndEdited(_ text: String?) {
        guard let account = text, !account.isEmpty else {
            self.view?.showAccountError()
            validateFields()
            return
        }
        self.view?.hideAccountError()
        self.view?.showAccountNumberError(with: true)
        self.validateFields()
    }

    func accountEdited(_ text: String?) {
        self.account = text
        self.validateFields()
    }

    func amountEndEdited(amount: Int?) {
        self.amount = amount
        validateFields()
    }

    func amountEdited(amount: Int?) {
        self.amount = amount
        if let unwrappedAmount = self.amount {
            view?.setAmount(with: unwrappedAmount.toCurrency())
        }
        validateFields()
    }
    
    func presentAccountNumberError() {
        view?.showAccountNumberError(with: false)
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

    func getBanks() {
        self.repository?.getBanks(onSuccess: { (banks) in
            self.banks = banks
            self.view?.reloadBanks()
            if let bankId = AccountManager.sharedInstance.getCashoutBank() {
                for (index, bank) in banks.enumerated() {
                    if bank.identifier == bankId {
                        self.view?.setSelectedBank(at: index)
                        self.view?.setBankTexField(bankName: bank.name)
                    }
                }
            }
        }, onFailure: { (error) in
            self.handle(error: error)
        })
    }
    
    func bankSelected(at row: Int) {
        guard let bank = banks.get(at: row) else { return }
        self.selectedBank = bank
        self.view?.setBankTexField(bankName: bank.name)
        validateFields()
    }
    
    func getBankName(at row: Int) -> String {
        guard let bank = banks.get(at: row) else { return ""}
        return bank.name
    }
    
    func getNumberOfBanks() -> Int {
        return banks.count
    }

    func confirmCashout() {
        self.view?.disableButton()
        self.view?.presentPasscode(onSuccess: passcodeSucceeded, onFailure: passcodeFailed)
    }

    func passcodeSucceeded() {
        self.view?.navigateToExecuteTransaction()
    }

    func passcodeFailed() {
        //once implemented we activate the button again
        self.view?.enableButton()
    }

    func getCashoutViewModel() -> CashoutViewModel? {
        guard let amount = amount,
            let accountNumber = account,
            let bank = selectedBank else {
            // handle this error
            return nil
        }
        
        let user = AccountManager.sharedInstance.getUser() ?? User(firstName: "", identifier: "", smallImage: "")
        let cashoutViewModel = CashoutViewModel(userViewModel: UserViewModel(user: user), amount: amount, accountNumber: accountNumber, bank: bank)
        return cashoutViewModel
    }
    
    func didTapHiddenButton() {
        view?.showNameAndRutCannotBeEditedToast()
    }

    // MARK: Private

    private func validateFields() {
        guard selectedBank != nil else {
            self.view?.disableButton()
            return
        }

        guard let account = account, !account.isEmpty else {
            self.view?.disableButton()
            self.view?.showAccountError()
            return
        }

        self.view?.hideAccountError()
        self.view?.showAccountNumberError(with: true)

        //Verify if amount != nil
        guard let amount = self.amount else {
            self.view?.disableButton()
            self.view?.hideBalanceError()
            return
        }

        //Hide the red line underneath the label
        self.view?.hideAmountError()

        //The point of this operation is to ensure the user has entered at least 3 numbers
        if amount >= self.minValueToValidateAmount {

            if amount < minAmount {
                view?.showAmountError(withMessage: "Monto mínimo a retirar $2.000")
                self.view?.disableButton()
                return
            } else if amount > maxAmount {
                view?.showAmountError(withMessage: "Monto máximo a retirar $500.000")
                self.view?.disableButton()
                return
            } else if amount > balance {
                view?.showAmountError(withMessage: "Monto excede saldo")
                self.view?.disableButton()
                return
            }
        } else {
            // If the user has not writen at least 3 numbers disable the button.
            self.view?.disableButton()
            return
        }
        //        self.view?.hideBalanceError()

        self.view?.enableButton()
    }

    //swiftlint:disable:next cyclomatic_complexity
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let withdrawError):
            guard let withdrawError = withdrawError as? WithdrawTEFError else { return }
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
            guard let withdrawError = withdrawError as? WithdrawTEFError else { return }
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
}
