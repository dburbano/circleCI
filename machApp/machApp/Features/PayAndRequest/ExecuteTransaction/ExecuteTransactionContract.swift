//
//  ExecuteTransactionContract.swift
//  machApp
//
//  Created by lukas burns on 3/30/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit


protocol ExecuteOperationDelegate: class {
    func actionWasDeniedBySmyte(with message: String)
}

protocol ExecuteTransactionViewProtocol: BaseViewProtocol {

    func navigateToChatDetail(with transaction: TransactionViewModel?)

    func navigateToCashoutATMDetail(with cashoutATMResponse: CashoutATMResponse)

    func navigateToCashoutATMDetail(with cashoutATMResponse: CashoutATMResponse, goToCreatedDialogue: Bool)

    func navigateToSelectAmountCashoutATM(with transactionError: ExecuteTransactionError)

    func navigateToSelectAmountCashoutATM(with apiError: ApiError)

    func setAmount(amount: Int)

    func setUserImage(imageURL: URL?, placeHolder: UIImage?)

    func showInitialPaymentMessage()

    func showInitialRequestMessage()

    func showInitialCashoutMessage()

    func showSuccessPaymentMessage()

    func showSuccessRequestMessage()

    func showSuccessCashoutMessage()

    func showFailedPaymentMessage()

    func showPaymentError()

    func showFailedRequestMessage()

    func showFailedCashoutMessage()

    func hideMessage()

    func setUserName(firstName: String, lastName: String)

    func closeView()

    func navigateToHome(with transactionError: ExecuteTransactionError)

    func navigateToHome()

    func setLoadingMessage(message: String)

    func showBlockedAction(with message: String)
    
    func hideSpinner()
    
    func playCheckAnimation()
    
    func navigateToWithdraw(with error: ExecuteTransactionError)

}

protocol ExecuteTransactionPresenterProtocol {

    func setView(view: ExecuteTransactionViewProtocol)

    func executeTransaction()

    func setMovementViewModel(_ movementViewModel: MovementViewModel?)

    func setTransactionMode(transactionMode: TransactionMode?)

    func setCashoutViewModel(_ cashoutViewModel: CashoutViewModel?)

    func setCashoutATMViewModel(_ cashoutATMViewModel: CashoutATMViewModel?)

}

protocol ExecuteTransactionRepositoryProtocol {

    func execute(payment: Payment, onSuccess: @escaping (Transaction?) -> Void, onFailure: @escaping (ApiError) -> Void)

    func execute(request: [RequestPayment], onSuccess: @escaping ([Transaction]?) -> Void, onFailure: @escaping (ApiError) -> Void)

    func executeMach(request: RequestPayment, onSuccess: @escaping (Transaction?) -> Void, onFailure: @escaping (ApiError) -> Void)

    func execute(cashout: Cashout, onSuccess: @escaping (Transaction?) -> Void, onFailure: @escaping (ApiError) -> Void)

    func saveTransaction(transaction: Transaction)

    func execute(cashoutATM: CashoutATM, onSuccess: @escaping(CashoutATMResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum ExecuteTransactionError: Error {
    case paymentFailed(message: String)
    case requestFailed(message: String)
    case cashoutFailed(message: String)
    case cashoutUnknownState(message: String)
    case cashoutMaxAttempts(message: String)
    case cashoutATMDailyMaxAttempts(message: String)
    case invalidSecurityHash(message: String)
    case internalServerError(message: String)
    case invalidAccountNumber
}

class ExecuteTransactionErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == Constants.ApiError.Payment.processorInsufficientBalance {
            return ApiError.clientError(error: ExecuteTransactionError.paymentFailed(message: ""))

        } else if networkError.errorType == Constants.ApiError.Transaction.processorTimeOutError {
            return ApiError.serverError(error: ExecuteTransactionError.cashoutUnknownState(message: ""))

        } else if networkError.errorType == Constants.ApiError.Transaction.ccaTimeOutError {
            return ApiError.serverError(error: ExecuteTransactionError.cashoutUnknownState(message: ""))

        } else if networkError.errorType == Constants.ApiError.Cashout.apiCashoutError {
            return ApiError.clientError(error: ExecuteTransactionError.cashoutFailed(message: ""))

        } else if networkError.errorType == Constants.ApiError.Cashout.processorCashoutError {
            return ApiError.clientError(error: ExecuteTransactionError.cashoutFailed(message: " "))

        } else if networkError.errorType == Constants.ApiError.Cashout.createMovementCashoutError {
            return ApiError.clientError(error: ExecuteTransactionError.cashoutFailed(message: " "))

        } else if networkError.errorType == Constants.ApiError.Cashout.cashoutNotFoundError {
            return ApiError.clientError(error: ExecuteTransactionError.cashoutFailed(message: " "))

        } else if networkError.errorType == Constants.ApiError.Cashout.processorAuthorizationDenied {
            return ApiError.clientError(error: ExecuteTransactionError.invalidAccountNumber)
            
        } else if networkError.errorType == Constants.ApiError.internalServerError {
            return ApiError.serverError(error: ExecuteTransactionError.internalServerError(message: ""))

        } else if networkError.errorType == Constants.ApiError.Transaction.invalidSecurityHash {
            return ApiError.serverError(error: ExecuteTransactionError.invalidSecurityHash(message: ""))

        } else if networkError.errorType == Constants.ApiError.CashoutATM.maxAttemptsError {
            return ApiError.clientError(error: ExecuteTransactionError.cashoutMaxAttempts(message: ""))

        } else if networkError.errorType == Constants.ApiError.CashoutATM.atmDailyAmountLimit {
            return ApiError.clientError(error: ExecuteTransactionError.cashoutATMDailyMaxAttempts(message: networkError.errorMessage!))
            
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
