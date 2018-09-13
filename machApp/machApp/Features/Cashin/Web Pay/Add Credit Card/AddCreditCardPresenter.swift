//
//  AddCreditCardPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/8/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class AddCreditCardPresenter: AddCreditCardPresenterProtocol {

    weak var view: AddCreditCardViewProtocol?
    var repository: AddCreditCardRepositoryProtocol?

    required init(repository: AddCreditCardRepositoryProtocol?) {
        self.repository = repository
    }

    // MARK: AddCreditCardPresenterProtocol
    func setView(view: AddCreditCardViewProtocol) {
        self.view = view
    }

    func getBalance() {
        self.repository?.getSavedBalance(response: {[weak self] (balance) in
            if let unwrappedBalance = balance, let unwrappedSelf = self {
                unwrappedSelf.view?.updateBalance(balance: Int(unwrappedBalance.balance).toCurrency())
            }
        })
        self.repository?.getBalance(onSuccess: { (balanceRessponse) in
            self.view?.updateBalance(balance: Int(balanceRessponse.balance).toCurrency())
        }, onFailure: { (error) in
            self.handle(error: error)
        })
    }

    func getURLForWebView() {
        repository?.fetchWebPayURL(onSuccess: {[weak self] response in
            self?.view?.displayWebView(with: response)
            }, onFailure: {[weak self] error in
                self?.handle(error: error)
        })
    }

    // MARK: - Private
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError :
            self.view?.showNoInternetConnectionError()
        case .serverError(let addCreditCardError):
            guard let error = addCreditCardError as? AddCreditCardError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch error {
            case .failed:
                break
            }
        case .clientError(let addCreditCardError):
            guard let error = addCreditCardError as? AddCreditCardError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch error {
            case .failed:
                break
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
}
