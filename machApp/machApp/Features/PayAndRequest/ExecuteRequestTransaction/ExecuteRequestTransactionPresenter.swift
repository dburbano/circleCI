//
//  ExecuteRequestTransactionPresenter.swift
//  machApp
//
//  Created by Rodrigo Russell on 3/6/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class ExecuteRequestTransactionPresenter: ExecuteRequestTransactionPresenterProtocol {

    var view: ExecuteRequestTransactionViewProtocol?
    var repository: ExecuteRequestTransactionRepositoryProtocol?

    required init(repository: ExecuteRequestTransactionRepositoryProtocol?) {
        self.repository = repository
    }

    func executeRequest(requestViewModel: MovementViewModel) {
        var requests: [RequestPayment] = []

        for request in requestViewModel.userAmountViewModels {
            requests.append(RequestPayment(
                fromMachId: request.user.machId,
                fromPhoneNumber: request.user.phone?.cleanPhoneNumber() ?? "",
                message: requestViewModel.message,
                amount: request.amount,
                metadata: requestViewModel.metaData
            ))
        }

        self.executeRequestWith(requestViewModel: requestViewModel, requests: requests)
    }

    private func executeRequestWith(requestViewModel: MovementViewModel, requests: [RequestPayment]) {
        self.repository?.execute(requests: requests, onSuccess: { (transaction) in
            BranchIOManager.sharedInstance.userCompletedActionWith(campaignEvent: .createRequest)
            //The tabBar tooltip should be hidden once the user finishes a request or a payment, different to mach team.
            ConfigurationManager.sharedInstance.didShowTabBarTooltip()
            self.view?.showSuccessRequestMessage()
            self.handleExecutionSuccessfull(transactions: transaction)
        }, onFailure: { (error) in
            self.handle(error: error)
        })

    }

    func handleExecutionSuccessfull(transactions: [Transaction]?) {
        if let transactions = transactions {
            for transaction in transactions {
                transaction.seen = true
                self.repository?.saveTransaction(transaction: transaction)
            }
        }
        Thread.runOnMainQueue(1.5, completion: {
            self.view?.navigateToHome()
        })
    }

    private func handle(error apiError: ApiError) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let executeTransactionError):
            guard let executeTransactionError = executeTransactionError as? ExecuteTransactionError else { return }
            self.handleRequestError(executeTransactionError: executeTransactionError)
        case .clientError(let executeTransactionError):
            guard let executeTransactionError = executeTransactionError as? ExecuteTransactionError else { return }
            self.handleRequestError(executeTransactionError: executeTransactionError)
        case .smyteError(let message):
            self.view?.showMessage(with: message)
        default:
            break
        }
        self.closeView(after: 3.0)
    }

    private func handleRequestError(executeTransactionError: ExecuteTransactionError) {
        switch executeTransactionError {
        case .requestFailed( _):
            self.view?.showFailedRequestMessage()
        default:
            self.view?.showServerError()
        }
    }

    private func closeView(after seconds: Double = 1.5) {
        Thread.runOnMainQueue(1.5) {
            self.view?.closeView()
        }
    }

    func setView(view: ExecuteRequestTransactionViewProtocol) {
        self.view = view
    }

}
