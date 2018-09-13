//
//  ExecuteRechargeRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/19/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class ExecuteRechargeRepository: ExecuteRechargeRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: ExecuteRechargeErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: ExecuteRechargeErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func recharge(with model: CashInCreditCard, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(CashService.rechargeCreditCard(parameters: model.toParams()), onSuccess: { _ in
                onSuccess()
            }, onError: { errorResponse in
                //swiftlint:disable:next force_unwrapping
                let error = self.errorParser!.getError(networkError: errorResponse)
                switch error {
                case .timeOutError:
                    onFailure(ApiError.serverError(error: ExecuteRechargeError.rechargeTimeOut(message: "")))
                default:
                    onFailure((self.errorParser?.getError(networkError: errorResponse))!)
                }

            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
}
