//
//  ExecuteRequestTransactionContract.swift
//  machApp
//
//  Created by Rodrigo Russell on 3/6/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

protocol ExecuteRequestTransactionViewProtocol: BaseViewProtocol {
    func showNoInternetConnectionError()
    func showFailedRequestMessage()
    func closeView()
    func showMessage(with text: String)
    func showSuccessRequestMessage()
    func navigateToHome()
}

protocol ExecuteRequestTransactionPresenterProtocol {
    func setView(view: ExecuteRequestTransactionViewProtocol)
    func executeRequest(requestViewModel: MovementViewModel)
}

protocol ExecuteRequestTransactionRepositoryProtocol {
    func execute(requests: [RequestPayment], onSuccess: @escaping ([Transaction]?) -> Void, onFailure: @escaping (ApiError) -> Void)
    func saveTransaction(transaction: Transaction)
}
