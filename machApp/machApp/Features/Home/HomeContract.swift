//
//  HomeContract.swift
//  machApp
//
//  Created by lukas burns on 3/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

protocol HomeViewProtocol: BaseViewProtocol {
    func updateBalance(response: HomeBalanceResponse)

    func updateHistory()

    func showSpinner()

    func hideSpinner()

    func showSpinnerOnTable()

    func hideSpinnerOnTable()

    func showActivityIndicator()

    func hideActivityIndicator()

    func showBluetoothButtonEnabled()

    func showBluetoothButtonDisabled()

    func askForLocationServicePermission()

    func hideAskForLocationView()

    func showUpdateBalanceFailure()

    func stopRefreshControl()
    
    func setCardIconWithAlert()
    
    func setCardIconWithoutAlert()
        
    func showCreditCardLoading()
    
    func hideCreditCardLoading()
    
    func navigateToHistory()
    
    func updateMoreBadge(with hiddenFlag: Bool)

    func goToMain()
    
}

protocol HomePresenterProtocol: BasePresenterProtocol {
    func createOnboardingTooltip() -> UIView?

    var transactionViewModel: TransactionViewModel? { get set }

    func getSignupDate()

    func setup()

    func getBalance(triggeredByUser: Bool)

    func getHistory()

    func getGroup(at indexPath: IndexPath) -> GroupViewModel

    func getGroup(for transaction: ChatMessageBaseViewModel) -> GroupViewModel?

    func areThereTransactions() -> Bool

    func setView(view: HomeViewProtocol)

    func getNumberOfGroups() -> Int

    func loadGroups()

    func userScrolledToLastGroup()

    func bluetoothButtonPressed()

    func locationPermissionAccepted()

    func locationPermissionRejected()

    func initializeBluetooth()

    func viewWillDissapear()

    func pullToRefresh()

    func getMachTeamProfile()
    
    func updateUserInfo()
    
    func historyTapped()
    
    func getAccountState()
}

protocol HomeRepositoryProtocol {
    func getSavedBalance(response: (Balance?) -> Void)

    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void)

    func getHistory(onSuccess: @escaping (Results<Group>) -> Void, onFailure: @escaping (ApiError) -> Void)

    func getGroupsAfter(lastGroup: Group?, onSuccess: @escaping ([Transaction]) -> Void, onFailure: @escaping (ApiError) -> Void)

    func getMachTeamProfile(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void)

    func fetchSignupDate()
    
    func getOwnProfile(onSuccess: @escaping (UserProfileResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    
    func isUsersMailValidated() -> Bool
}

enum HomeError: Error {
    case failed(message: String)
    case userAlreadyHasCard(message: String)
    case prepaidCardUserVerificationNeeded(message: String)
}

class HomeErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "user_already_has_card" {
            return ApiError.clientError(error: HomeError.userAlreadyHasCard(message: ""))
        } else if networkError.errorType == "prepaid_cards_user_verification_needed" {
            return ApiError.clientError(error: HomeError.prepaidCardUserVerificationNeeded(message: ""))
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
