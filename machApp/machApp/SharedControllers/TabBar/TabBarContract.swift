//
//  TabBarContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

protocol TabBarViewProtocol: class {
    func navigateToPrepaidCards(with cards: [PrepaidCard])
    func showServerError()
    func showLoadingIndicator(with hiddenFlag: Bool)
    func navigateToStartAuthenticationProcess()
    func dismissAuthenticationProcess()
}

protocol TabBarPresenterProtocol: BasePresenterProtocol, AuthenticationDelegate {
    func setView(view: TabBarViewProtocol)
    func getHistory()
    func areThereTransactions() -> Bool
    func getCreditCard()
}

protocol TabBarRepositoryProtocol {
    func getHistory(onSuccess: @escaping (Results<Group>) -> Void, onFailure: @escaping () -> Void)
    func getPrepaidCards(onSuccess: @escaping ([PrepaidCard]) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getLocalPrepaidCards(onSuccess: @escaping ([PrepaidCard]) -> Void, onFailure: () -> Void)
}

enum TabError: Error {
    case userAlreadyHasCard(message: String)
    case prepaidCardUserVerificationNeeded(message: String)
}

class TabErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "user_already_has_card" {
            return ApiError.clientError(error: TabError.userAlreadyHasCard(message: ""))
        } else if networkError.errorType == "prepaid_cards_user_verification_needed" {
            return ApiError.clientError(error: TabError.prepaidCardUserVerificationNeeded(message: ""))
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
