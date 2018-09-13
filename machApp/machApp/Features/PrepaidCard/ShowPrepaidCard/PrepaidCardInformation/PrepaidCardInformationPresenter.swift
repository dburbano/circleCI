//
//  PrepaidCardInformationPresenter.swift
//  machApp
//
//  Created by Lukas Burns on 7/31/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class PrepaidCardInformationPresenter {
    
    weak var view: PrepaidCardInformationViewProtocol?
    var repository: PrepaidCardInformationRepositoryProtocol?
    
    var isCardDetailShown: Bool
    var prepaidCard: PrepaidCard?
    
    var delegate: PrepaidCardInformationDelegate?
    
    init(repository: PrepaidCardInformationRepositoryProtocol?) {
        self.repository = repository
        self.isCardDetailShown = false
    }
    
    func setup(prepaidCard: PrepaidCard?) {
        self.prepaidCard = prepaidCard
        self.showCardPreview()
    }
    
    func setDelegate(delegate: PrepaidCardInformationDelegate?) {
        self.delegate = delegate
    }

    // MARK: - Private Function

    func showOrHidePrepaidCardInformation() {
        if isCardDetailShown {
            self.showCardPreview()
            isCardDetailShown = !isCardDetailShown
        } else {
            self.delegate?.prepaidCardDetailRequested(onSuccess: {
                if self.prepaidCard?.cvv != nil, self.prepaidCard?.pan != nil {
                    self.showCardDetail()
                } else {
                    self.getCardDetailAndShow()
                }
            }, onFailure: {
                // Failed, do nothing
            })
        }
    }

    private func getCardDetailAndShow() {
        guard let prepaidCardId = self.prepaidCard?.id else { return }
        self.getCVV(for: prepaidCardId)
        self.getPAN(for: prepaidCardId)
        self.view?.setSeeCardDetailButtonAsLoading()
    }
    
    private func getCVV(for cardId: String) {
        self.repository?.getPrepaidCardCVVFor(prepaidCardId: cardId, onSuccess: { (prepaidCardCVVResponse) in
            self.prepaidCard?.cvv = prepaidCardCVVResponse.cvv
            self.showCardDetail()
        }, onFailure: { (error) in
            self.handle(error: error, showDefaultError: true)
        })
    }
    
    private func getPAN(for cardId: String) {
        self.repository?.getPrepaidCardPANFor(prepaidCardId: cardId, onSuccess: { (prepaidCardPANResponse) in
            self.prepaidCard?.pan = prepaidCardPANResponse.pan
            self.showCardDetail()
        }, onFailure: { (error) in
            self.handle(error: error, showDefaultError: true)
        })
    }
    private func showCardDetail() {
        guard let pan = self.prepaidCard?.pan, let cvv = self.prepaidCard?.cvv else {
            self.view?.setSeeCardDetailButtonText(text: "Ver datos")
            self.view?.setShowIconToCardDetailButton()
            return
        }
        self.isCardDetailShown = !self.isCardDetailShown
        self.delegate?.prepaidCardInformationShown()
        self.view?.setPAN(digits: pan)
        self.view?.setCVV(digits: cvv)
        self.view?.setSeeCardDetailButtonText(text: "Ocultar Datos")
        self.view?.setHideIconToCardDetailButton()
    }
    private func showCardPreview() {
        if let cardHolderName = self.prepaidCard?.holderName, let expirationMonth = self.prepaidCard?.expirationMonth,
            let expirationYear = self.prepaidCard?.expirationYear, let last4Pan = self.prepaidCard?.last4Pan {
            self.delegate?.prepaidCardInformationHidden()
            self.view?.setCardHolderName(name: cardHolderName)
            self.view?.setExpirationDate(date: "\(expirationMonth)/\(expirationYear)")
            self.view?.setPAN(digits: "************\(last4Pan)")
            self.view?.setCVV(digits: "***")
            self.view?.setSeeCardDetailButtonText(text: "Ver datos")
            self.view?.setShowIconToCardDetailButton()
        }
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
}

extension PrepaidCardInformationPresenter :PrepaidCardInformationPresenterProtocol {

    func set(view: PrepaidCardInformationViewProtocol) {
        self.view = view
    }
}
