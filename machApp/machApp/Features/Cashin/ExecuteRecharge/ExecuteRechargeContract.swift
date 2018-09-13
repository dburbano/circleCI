//
//  ExecuteRechargeContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/19/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation


protocol ExecuteRechargeViewProtocol: BaseViewProtocol {
    func didRechargeCreditCard(with value: String)
    func navigateToCreditCardError()
    func navigateToTimeoutError()
    func showErrorAndDismiss()
    func navigateToLimitError()
    func showBlockedAction(with message: String)
    func closeView()
}

protocol ExecuteRechargePresenterProtocol: BasePresenterProtocol {
    func setView(view: ExecuteRechargeViewProtocol)
    func rechargeAccount(with info: RechargeViewInfo)
}

protocol ExecuteRechargeRepositoryProtocol {
    func recharge(with model: CashInCreditCard, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum ExecuteRechargeError: Error {
    case creditCardError(message: String)
    case rechargeTimeOut(message: String)
    case limitError()
}

class ExecuteRechargeErrorParser: ErrorParser {
    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "cash_in_webpay_oneclick_card_error"
        || networkError.errorType == "cash_in_webpay_oneclick_rollback" {
            return ApiError.clientError(error: ExecuteRechargeError.creditCardError(message: ""))
        } else if networkError.errorType == "cash_in_webpay_oneclick_limit_error" {
            return ApiError.clientError(error: ExecuteRechargeError.limitError())
        } else if networkError.errorType == "cash_in_webpay_oneclick_webpay_timeout_error"
            || networkError.errorType == "cash_in_webpay_oneclick_processor_timeout_error"
            || networkError.errorType == "processor_timeout_error"
            || networkError.errorType == "cca_network_timeout_error" {
            return ApiError.serverError(error: ExecuteRechargeError.rechargeTimeOut(message: ""))
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
