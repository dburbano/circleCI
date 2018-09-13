//
//  PrepaidCardContract.swift
//  machApp
//
//  Created by Lukas Burns on 3/19/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol PrepaidCardViewProtocol: BaseViewProtocol{
    func updateBalance(balance: Int)
    func showBlurredOverlay()
    func hideBlurredOverlay()
    func presentPasscode(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void, with text: String)
    func showAmount()
    func hideAmount()
    func showTimer()
    func hideTimer()
    func updateTimer(with remainingSeconds: Int)
    func updateExchangeRate(rate: Float)
    func updateBalanceInUSD(usdBalance: Float)
    func navigateToRemovingPrepaidCard()
    func showTip(with message: NSAttributedString?, flag: Bool)
}

protocol PrepaidCardPresenterProtocol: BasePresenterProtocol, PrepaidCardInformationDelegate {
    func setView(view: PrepaidCardViewProtocol)
    func setup(prepaidCard: PrepaidCard?)
    func set(prepaidCardInformationPresenter: PrepaidCardInformationPresenterProtocol?)
    func removePrepaidCard()
}

protocol PrepaidCardRepositoryProtocol {
    func getSavedBalance(response: (Balance?) -> Void)
    func getUSDExchangeRate(onSuccess: @escaping (USDExchangeRateResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func removePrepaidCard(prepaidCardId: String, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
    func fetchTipMessage(response: (String) -> Void)
}

enum PrepaidCardError: Error {

}

class PrepaidCardErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
