//
//  RechargePresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/9/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

enum CreditCardImageName: String {
    case visa = "Visa"
    case masterCard  = "MasterCard"
    case americanExpress = "AmericanExpress"
    case diners = "Diners"
    case magna = "Magna"
}

class RechargePresenter: RechargePresenterProtocol {

    // MARK: Constants
    let upperBoundAmmount: Int = 500000
    let maximumRechargeAmount: Int = 250000

    // MARK: Variables
    weak var view: RechargeViewProtocol?
    var repository: RechargeRepositoryProtocol?
    var creditCardResponse: CreditCardResponse?
    var balance: Int?

    required init(repository: RechargeRepositoryProtocol?) {
        self.repository = repository
    }

    // MARK: RechargePresenterProtocol
    func setView(view: RechargeViewProtocol) {
        self.view = view
    }

    func amountEdited(amount: Int?) {
        if let amount = amount {
            if let balance = balance {
                //If the user ha a balance greater than 500.000, then he cannot recharge
                if balance >= upperBoundAmmount {
                    view?.presentAmountError(with: .withdraw(message: "Por ahora puedes cargar hasta \(0.toCurrency())"))
                    return
                }

                //A user can recharge maximum 500.000 - balance
                let maximumAmount =  upperBoundAmmount - balance

                if amount > maximumRechargeAmount {
                    view?.presentAmountError(with: .overUpperBoundAmmount(message: "El máximo es \(maximumRechargeAmount.toCurrency()) por recarga"))
                } else if amount > maximumAmount {
                    view?.presentAmountError(with: .withdraw(message: "Por ahora puedes cargar hasta \(maximumAmount.toCurrency())"))
                } else {
                    //Este es el caso en el que todo funciona
                    view?.presentAmountError(with: .normal(message: "Máximo \(maximumRechargeAmount.toCurrency()) por recarga"))
                }
            }
            view?.updateAmount(with: amount.toCurrency())
        }
    }

    func getCreditCardImageName(with name: String) {
        guard let imageName = CreditCardImageName(rawValue: name) else {
            self.view?.updateCreditCardImage(with: "logoMastercardColor")
            return }
        switch imageName {
        case .visa:
            self.view?.updateCreditCardImage(with: "logoVisaColor")
        case .masterCard:
            self.view?.updateCreditCardImage(with: "logoMastercardColor")
        case .americanExpress:
            self.view?.updateCreditCardImage(with: "logoAmexColor")
        case .diners:
            self.view?.updateCreditCardImage(with: "logoDinersColor")
        case .magna:
            self.view?.updateCreditCardImage(with: "logoMagnaColor")
        }
    }

    func setCreditCardLabel(with creditCard: CreditCardResponse) {
        let responseString = "\(creditCard.creditCardType) ****\(creditCard.last4Digits)"
        view?.updateCreditCardLabel(with: responseString)
    }

    func deleteCreditCard() {
        if let creditCard = creditCardResponse {
            self.repository?.deleteCreditCard(with: creditCard.id, onSuccess: {[weak self] in
                self?.view?.didDeleteCreditCard()
            }, onFailure: {[weak self] error in
                    self?.handle(error: error, showDefaultError: true)
            })
        }
    }

    func getBalance() {
        self.repository?.getSavedBalance(response: {[weak self] (balance) in
            if let unwrappedBalance = balance, let unwrappedSelf = self {
                unwrappedSelf.view?.updateBalance(balance: Int(unwrappedBalance.balance))
            }
        })
        self.repository?.getBalance(onSuccess: { (balanceRessponse) in
            self.view?.updateBalance(balance: Int(balanceRessponse.balance))
        }, onFailure: { (cashInError) in
            self.handle(error: cashInError)
        })
    }

    func rechargeAccount(with amount: String) {
        if creditCardResponse != nil {
            view?.presentPasscode(onSuccess: passcodeSucceeded, onFailure: passcodeFailed)
        }
    }

    // MARK: - Private
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError :
            self.view?.showNoInternetConnectionError()
        case .serverError(let cashInError):
            guard let cashInError = cashInError as? RechargeError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch cashInError {
            case .failed:
                break
            }
        case .clientError(let cashInError):
            guard let cashInError = cashInError as? RechargeError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch cashInError {
            case .failed:
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

    private func passcodeFailed() {
        print("passcodeFailed")
    }
}
