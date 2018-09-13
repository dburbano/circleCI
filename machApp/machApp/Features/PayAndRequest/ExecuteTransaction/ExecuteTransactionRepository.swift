//
//  ExecuteTransactionRepository.swift
//  machApp
//
//  Created by lukas burns on 3/30/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

class ExecuteTransactionRepository: ExecuteTransactionRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: ExecuteTransactionErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: ExecuteTransactionErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func execute(payment: Payment, onSuccess: @escaping (Transaction?) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(PaymentService.create(parameters: payment.toParams()),
                onSuccess: { (networkResponse) in
                    do {
                        //swiftlint:disable:next force_unwrapping
                        let transaction = try Transaction.create(from: networkResponse.body!)
                        onSuccess(transaction)
                    } catch {
                        ExceptionManager.sharedInstance.recordError(error)
                        onSuccess(nil)
                    }
            }, onError: { (errorResponse) in
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    func execute(request: [RequestPayment], onSuccess: @escaping ([Transaction]?) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            let requests = RequestPayments(requests: request)
            try apiService?.request(RequestService.create(parameters: requests.toParams()),
                onSuccess: { (networkResponse) in
                    do {
                        //swiftlint:disable:next force_unwrapping
                        let transaction = try Transaction.createArray(from: networkResponse.body!)
                        onSuccess(transaction)
                    } catch {
                        ExceptionManager.sharedInstance.recordError(error)
                        onSuccess(nil)
                    }
            }, onError: { (errorResponse) in
                //swiftlint:disable:next force_unwrapping
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            ExceptionManager.sharedInstance.recordError(error)
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    func executeMach(request: RequestPayment, onSuccess: @escaping (Transaction?) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(OnboardingService.create(parameters: request.toParams()),
                                    onSuccess: { (networkResponse) in
                                        do {
                                            //swiftlint:disable:next force_unwrapping
                                            let transaction = try Transaction.create(from: networkResponse.body!)
                                            onSuccess(transaction)
                                        } catch {
                                            ExceptionManager.sharedInstance.recordError(error)
                                            onSuccess(nil)
                                        }
            }, onError: { (errorResponse) in
                //swiftlint:disable:next force_unwrapping
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    internal func execute(cashout: Cashout, onSuccess: @escaping (Transaction?) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(CashService.out(parameters: cashout.toParams()), onSuccess: { (networkResponse) in
                do {
                    // swiftlint:disable:next force_unwrapping
                    let cashoutResponse = try Transaction.create(from: networkResponse.body!)
                    onSuccess(cashoutResponse)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    //TODO: Este es un caso excepcional en el que el server responde vacío pero la operación sí se hizo.
                    onSuccess(nil)
                }
            }, onError: { (errorResponse) in
                let error = self.errorParser?.getError(networkError: errorResponse)
                switch error! {
                case .timeOutError():
                    onFailure(ApiError.serverError(error: ExecuteTransactionError.cashoutUnknownState(message: "")))
                default:
                    onFailure(error!)
                }
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    func execute(cashoutATM: CashoutATM, onSuccess: @escaping (CashoutATMResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.requestAndDecrypt(CashService.cashoutATM(parameters: cashoutATM.toParams()), onSuccess: { (JSONResponse) in
                do {
                    let cashoutATMResponse = try CashoutATMResponse.create(from: JSONResponse)
                    onSuccess(cashoutATMResponse)
                } catch {
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (errorResponse) in
                //swiftlint:disable:next force_unwrapping
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        } catch {
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    func saveTransaction(transaction: Transaction) {
        do {
            try TransactionManager.handleTransactionReceived(transaction: transaction)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

}
