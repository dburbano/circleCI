//
//  ExecuteRequestTransactionRepository.swift
//  machApp
//
//  Created by Rodrigo Russell on 3/8/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class ExecuteRequestTransactionRepository: ExecuteRequestTransactionRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: ExecuteTransactionErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: ExecuteTransactionErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func execute(requests: [RequestPayment], onSuccess: @escaping ([Transaction]?) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            let requests = RequestPayments(requests: requests)
            try apiService?.request(
                RequestService.create(parameters: requests.toParams()),
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
                }
            )
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            ExceptionManager.sharedInstance.recordError(error)
            //swiftlint:disable:next force_unwrapping
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
