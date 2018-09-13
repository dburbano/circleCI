//
//  WebViewRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/8/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class WebViewRepository: WebRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: WebErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: WebErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func callEndpoint(with model: SignUpCreditCard, onSuccess: @escaping (CreditCardResponse) -> Void, onFailure: @escaping (ApiError) -> Void ) {
        do {
            try apiService?.request(CashService.finishCreditCardInscription(parameters: model.toParams()), onSuccess: {[weak self] networkResponse in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let creditCardResponse = try CreditCardResponse.create(from: networkResponse.body!)
                    //Save the credit card
                    CreditCardManager.sharedInstance.set(creditCard: creditCardResponse)
                    onSuccess(creditCardResponse)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    //swiftlint:disable:next force_unwrapping
                    onFailure((self?.errorParser?.getError(error: error))!)
                }

            }, onError: {[weak self] errorResponse in
                //swiftlint:disable:next force_unwrapping
                onFailure((self?.errorParser?.getError(networkError: errorResponse))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
}
