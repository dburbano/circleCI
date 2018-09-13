//
//  HistoryPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/2/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class HistoryPresenter: HistoryPresenterProtocol {

    weak var view: HistoryViewProtocol?
    var repository: HistoryRepositoryProtocol?

    required init(repository: HistoryRepositoryProtocol?) {
        self.repository = repository
    }

    // MARK: HistoryViewProtocol
    func setView(view: HistoryViewProtocol) {
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
        }, onFailure: { (historyError) in
            self.handle(error: historyError)
        })
    }

    // MARK: - Private
    private func handle(error apiError: ApiError) {
        switch apiError {
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let historyError):
            guard let historyError = historyError as? HistoryError else { return }
            self.view?.showServerError()
            switch historyError {
            case .failed:
                break
            }
        case .clientError(let historyError):
            guard let historyError = historyError as? HistoryError else { return }
            self.view?.showServerError()
            switch historyError {
            case .failed:
                break
            }
        default:
            self.view?.showServerError()
        }
    }
}
