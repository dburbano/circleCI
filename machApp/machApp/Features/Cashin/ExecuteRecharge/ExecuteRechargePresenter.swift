//
//  ExecuteRechargePresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/19/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class ExecuteRechargePresenter: ExecuteRechargePresenterProtocol {

    // MARK: Variables
    weak var view: ExecuteRechargeViewProtocol?
    var repository: ExecuteRechargeRepositoryProtocol?

    required init(repository: ExecuteRechargeRepositoryProtocol?) {
        self.repository = repository
    }

    // MARK: ExecuteRechargePresenterProtocol
    func setView(view: ExecuteRechargeViewProtocol) {
        self.view = view
    }

    func rechargeAccount(with info: RechargeViewInfo) {
        repository?.recharge(with: CashInCreditCard(with: info.creditCardID, amount: String.clearTextFormat(text: info.amount)), onSuccess: {[weak self] in
            self?.view?.didRechargeCreditCard(with: info.amount)
            }, onFailure: {[weak self] error in
                self?.handle(error: error)
        })
    }

    // MARK: Private

    private func handle(error apiError: ApiError) {
        switch apiError {
        case .unauthorizedError():
            break
        case .serverError(let executeRechargeError), .clientError(let executeRechargeError):
            guard let executeRechargeError = executeRechargeError as? ExecuteRechargeError else { return }
            switch executeRechargeError {
            case .creditCardError:
                view?.navigateToCreditCardError()
            case .rechargeTimeOut:
                view?.navigateToTimeoutError()
            case .limitError:
                view?.navigateToLimitError()
            }
        case .smyteError(let message):
            view?.showBlockedAction(with: message)
            closeView()
        default:
            view?.showErrorAndDismiss()
        }
    }
    
    private func closeView(after seconds: Double = 1.5) {
        Thread.runOnMainQueue(seconds) {
            self.view?.closeView()
        }
    }
}
