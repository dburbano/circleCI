//
//  HistoryContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/2/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol HistoryViewProtocol: BaseViewProtocol {
    func updateBalance(balance: String)
}

protocol HistoryPresenterProtocol: BasePresenterProtocol {
    func getBalance()
    func setView(view: HistoryViewProtocol)
}
protocol HistoryRepositoryProtocol {
    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getSavedBalance(response: (Balance?) -> Void)
}

enum HistoryError: Error {
    case failed(message: String)
}

class HistoryErrorParser: ErrorParser {
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
