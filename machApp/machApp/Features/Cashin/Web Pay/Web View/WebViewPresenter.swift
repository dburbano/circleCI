//
//  WebViewPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/8/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class WebViewPresenter: WebPresenterProtocol {

    weak var view: WebViewProtocol?
    var repository: WebRepositoryProtocol?

    required init(repository: WebRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: WebViewProtocol) {
        self.view = view
    }

    func callEndpoint(with token: String) {
        let model = SignUpCreditCard(token: token)
        repository?.callEndpoint(with: model, onSuccess: {[weak self] response in
            self?.view?.didSignUpCreditCard(with: response)
        }, onFailure: {[weak self] error in
            self?.handle(error: error)
        })
    }

    private func handle(error apiError: ApiError) {
        switch apiError {
        case .unauthorizedError():
            break
        case .smyteError(let message):
            view?.showBlockAction(with: message)
            closeView()
        default:
            view?.couldntSignupCreditCard()
        }
    }
    
    private func closeView(after seconds: Double = 1.5) {
        Thread.runOnMainQueue(seconds) {
            self.view?.closeView()
        }
    }
}
