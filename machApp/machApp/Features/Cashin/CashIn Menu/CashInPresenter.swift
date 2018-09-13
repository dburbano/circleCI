//
//  CashInPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 10/24/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class CashInPresenter: CashInPresenterProtocol {

    weak var view: CashInViewProtocol?
    var repository: CashInRepositoryProtocol?

    required init(repository: CashInRepositoryProtocol?) {
        self.repository = repository
    }

    // MARK: CashInPresenterProtocol
    func setView(view: CashInViewProtocol) {
        self.view = view
    }

    func viewDidLoad() {
        SegmentAnalytics.Event.cashInAccessed(location:
        SegmentAnalytics.EventParameter.LocationType().navbar).track()
    }
    
    func getBalance() {
        self.repository?.getSavedBalance(response: {[weak self] (balance) in
            if let unwrappedBalance = balance, let unwrappedSelf = self {
                unwrappedSelf.view?.updateBalance(balance: Int(unwrappedBalance.balance).toCurrency())
            }
        })
        self.repository?.getBalance(onSuccess: { (balanceRessponse) in
            self.view?.updateBalance(balance: Int(balanceRessponse.balance).toCurrency())
        }, onFailure: { (cashInError) in
            self.handle(error: cashInError)
        })
    }

    func getCreditCard() {
        self.repository?.getCreditCard(onSuccess: {[weak self] creditCardResponse in
            guard let creditCard = creditCardResponse else {
                self?.view?.thereIsNotACreditCard()
                return
            }
            self?.view?.thereIsA(creditCard: creditCard)
        }, onFailure: {[weak self] errorResponse in
            self?.handle(error: errorResponse)
        })
    }

    func getAccountInformation() {
        self.view?.setTefButtonAsLoading()
        self.repository?.getAccountInformation(onSuccess: {[weak self] (accountInfo) in
            self?.view?.setTefButtonAsActive()
            self?.view?.dismissAuthenticationProcess()
            self?.view?.navigateToCashInDetailWith(accountInfo: accountInfo)
            }, onFailure: { (cashInError) in
                self.view?.setTefButtonAsActive()
                self.handle(error: cashInError)
        })
    }

    // MARK: - Private
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let cashInError):
            guard let cashInError = cashInError as? CashInError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch cashInError {
            case .userVerificationNeeded:
                break;
            }
        case .clientError(let cashInError):
            guard let cashInError = cashInError as? CashInError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch cashInError {
            case .userVerificationNeeded:
                self.view?.navigateToStartAuthenticationProcess()
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
}

extension CashInPresenter: AuthenticationDelegate {
    func authenticationProcessClosed() {
        self.view?.closeAuthenticationProcess()
    }
    
    func authenticationSucceeded() {
        self.view?.closeAuthenticationProcess()
        self.getAccountInformation()
    }

    func authenticationFailed() {
        self.view?.closeAuthenticationProcess()
    }
}
