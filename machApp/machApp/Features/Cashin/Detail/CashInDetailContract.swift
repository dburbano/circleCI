//
//  CashInDetailContract.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/10/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

protocol CashInDetailViewProtocol: BaseViewProtocol {
    func updateAccountInfo(info: AccountInformationResponse)
    func showSpinner()
    func hideSpinner()
    func updateBalance(balance: Int)
    func showToastWhenCopied()
    func shareData(withString string: String, excludedTypes: [UIActivityType])
    func showTip(with message: NSAttributedString)
}

protocol CashInDetailPresenterProtocol: BasePresenterProtocol {
    var accountInfo: AccountInformationResponse? { set get }
    func getBalance()
    func setView(view: CashInDetailViewProtocol)
    func copyToClipboard(string: String?)
    func shareData()
    func getTipMessage()
}

protocol CashInDetailRepositoryProtocol {
    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getSavedBalance(response: (Balance?) -> Void)
    func fetchtipMessage(response: (String) -> Void)
}

enum CashInError: Error {
    case userVerificationNeeded(message: String)
}

class CashInErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == Constants.ApiError.Cashin.userVerifitacionNeeded {
            return ApiError.clientError(error: CashInError.userVerificationNeeded(message: ""))
        }
        return super.getError(networkError: networkError)
    }
}
