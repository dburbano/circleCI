//
//  WebViewContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/8/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol WebViewProtocol: BaseViewProtocol {
    func didSignUpCreditCard(with response: CreditCardResponse)
    func couldntSignupCreditCard()
    func showBlockAction(with message: String)
    func closeView()
}

protocol WebPresenterProtocol: BasePresenterProtocol {
    func setView(view: WebViewProtocol)
    func callEndpoint(with token: String)
}

protocol WebRepositoryProtocol {
    func callEndpoint(with model: SignUpCreditCard, onSuccess: @escaping (CreditCardResponse) -> Void, onFailure: @escaping (ApiError) -> Void )
}

enum CreditCardSignupResponse {
    case success(response: CreditCardResponse)
    case failure

    func get() -> Any? {
        switch self {
        case .success(let response):
            return response
        case .failure:
            return nil
        }
    }
}

class WebErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
