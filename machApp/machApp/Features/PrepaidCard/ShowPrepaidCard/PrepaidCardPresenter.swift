//
//  PrepaidCardPresenter.swift
//  machApp
//
//  Created by Lukas Burns on 3/19/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class PrepaidCardPresenter: PrepaidCardPresenterProtocol {
    
    weak var view: PrepaidCardViewProtocol?
    var repository: PrepaidCardRepositoryProtocol?

    let secondsAllowedForCardDetailToBeShown: Int = 60
    var secondsRemainingForCardDetailToBeShown: Int = 0
    
    var prepaidCardInformationPresenter: PrepaidCardInformationPresenterProtocol?

    var prepaidCard: PrepaidCard?
    var timer = Timer()
    var balance: Int
    var usdExchangeRate: Float?
    
    required init(repository: PrepaidCardRepositoryProtocol?) {
        self.repository = repository
        self.balance = 0
    }
    
    func setView(view: PrepaidCardViewProtocol) {
        self.view = view
    }
    
    func setup(prepaidCard: PrepaidCard?) {
        self.prepaidCard = prepaidCard
        self.getUSDExchange()
        self.initializeBalance()
    }
    
    func set(prepaidCardInformationPresenter: PrepaidCardInformationPresenterProtocol?) {
        self.prepaidCardInformationPresenter = prepaidCardInformationPresenter
    }
    
    private func initializeBalance() {
        repository?.getSavedBalance(response: {[weak self] (balance) in
            if let unwrappedBalance = balance, let unwrappedSelf = self {
                unwrappedSelf.balance = Int(unwrappedBalance.balance)
                unwrappedSelf.view?.updateBalance(balance: unwrappedSelf.balance)
                self?.updateUSDInformation()
            }
        })
        self.repository?.getBalance(onSuccess: { (balanceResponse) in
            self.balance = Int(balanceResponse.balance)
            self.view?.updateBalance(balance: self.balance)
            self.updateUSDInformation()
        }, onFailure: { (error) in
            self.handle(error: error)
        })
    }
    
    func startTimer() {
         self.secondsRemainingForCardDetailToBeShown = self.secondsAllowedForCardDetailToBeShown
         self.view?.updateTimer(with: self.secondsRemainingForCardDetailToBeShown)
         timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerHasChanged), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.timer.invalidate()
    }
    
    @objc private func timerHasChanged() {
        self.secondsRemainingForCardDetailToBeShown -= 1
        guard self.secondsRemainingForCardDetailToBeShown != 0 else {
            self.timerHasExpired()
            return
        }
        self.view?.updateTimer(with: self.secondsRemainingForCardDetailToBeShown)
    }
    
    private func timerHasExpired() {
        self.stopTimer()
        self.prepaidCardInformationPresenter?.showOrHidePrepaidCardInformation()
    }
    
    private func getUSDExchange() {
         self.repository?.getUSDExchangeRate(onSuccess: { (usdExchangeRateResponse) in
            self.usdExchangeRate = usdExchangeRateResponse.exchangeRate.rounded(toPlaces: 0)
            self.updateUSDInformation()
         }, onFailure: { (error) in
            self.handle(error: error)
            self.updateUSDInformation()
         })
    }
    
    private func updateUSDInformation() {
        guard let rate = usdExchangeRate else { return }
        self.view?.updateBalanceInUSD(usdBalance: Float(self.balance) / rate)
        self.view?.updateExchangeRate(rate: rate)
    }

    func removePrepaidCard() {
        self.view?.presentPasscode(onSuccess: pinSucceeded, onFailure: pinFailed, with: "Ingresa tu PIN para continuar")
    }

    private func pinSucceeded() {
        guard let prepaidCardId = self.prepaidCard?.id else { return }
        self.repository?.removePrepaidCard(prepaidCardId: prepaidCardId, onSuccess: {
            // success
        }, onFailure: { (apiError) in
            // error
            self.handle(error: apiError, showDefaultError: true)
        })
        self.view?.navigateToRemovingPrepaidCard()
    }

    private func pinFailed() {
        // Record Analytic
    }

    // MARK: - Private
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError:
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let prepaidError):
            guard let prepaidError = prepaidError as? PrepaidCardError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch prepaidError {
            default:
                break
            }
        case .clientError(let prepaidError):
            guard let prepaidError = prepaidError as? PrepaidCardError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch prepaidError {
            default:
                break
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
    
    func showTip() {
        repository?.fetchTipMessage(response: {[weak self] response in
            let title = response
            let titleNSString = NSString.init(string: title)
            let attString = NSMutableAttributedString(string: title,
                                                      // swiftlint:disable:next force_unwrapping
                attributes: [NSAttributedStringKey.font: UIFont(name: "Nunito-Regular", size: 13.0)!,
                             NSAttributedStringKey.foregroundColor: UIColor.white])
            let range = titleNSString.range(of: "Ver historial")
            // swiftlint:disable:next force_unwrapping
            attString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Nunito-Bold", size: 13.0)!, range: range)
            self?.view?.showTip(with: attString, flag: true)
        })
    }
}

extension PrepaidCardPresenter: PrepaidCardInformationDelegate {
    func prepaidCardInformationShown() {
        self.view?.showBlurredOverlay()
        self.view?.hideAmount()
        self.startTimer()
        self.showTip()
        self.view?.showTimer()
    }
    
    func prepaidCardInformationHidden() {
        self.view?.hideBlurredOverlay()
        self.view?.hideTimer()
        self.view?.showTip(with: nil, flag: false)
        self.view?.showAmount()
        self.stopTimer()
    }
    
    func prepaidCardDetailRequested(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        self.view?.presentPasscode(onSuccess: onSuccess, onFailure: onFailure, with: "Ingresa tu PIN para ver los datos de tu tarjeta")
    }
}
