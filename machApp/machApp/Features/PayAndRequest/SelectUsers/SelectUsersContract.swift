//
//  SelectUsersContract.swift
//  machApp
//
//  Created by lukas burns on 3/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

protocol SelectUsersViewProtocol: BaseViewProtocol {

    func updateUsers()

    func updateSelectedUsers()

    func askForContactsPermission()

    func removeAskForPermissionView()

    func navigateToSelectAmount()

    func showUsersSelectedView()

    func hideUsersSelectedView()

    func showContinueButton()

    func hideContinueButton()

    func showNumberOfSelectedUsersLabel(numberOfSelectedUsers: Int)

    func hideNumberOfSelectedUsersLabel()

    func insertPlaceholder()

    func removePlaceholder()

    func goBackToHome()

    func showConfirmationAlert(title: String, message: String, onAccepted: @escaping () -> Void, onCancelled: @escaping () -> Void)

    func searchBarResignFirstResponder()

    func showIncorrectNumberOfUsersError()

    func showIncorrectNumberOfUsersError(maxSelecteableUsers: Int)

    func setPaymentTitle()

    func setRequestTitle()

    func showBluetoothButtonEnabled()

    func showBluetoothButtonDisabled()

    func askForLocationServicePermission()

    func hideAskForLocationView()

    func reloadNearUsersSection()

    func insertUsers(at indexPaths: [IndexPath])
    
    func updateUsers(at indexPaths: [IndexPath])

    func insertUser(at position: Int)

    func removeUser(at position: Int)

    func showNonMachUserError()

    func inviteANonMachUser(with url: URL, text: String)

    func updateChargeMachTeamView()

    func showContinueTooltip(with flag: Bool)

    func inviteNonMachFriends(withString string: String, url: URL, excludedTypes: [UIActivityType])

    func shouldPresentInviteUsersView(with flag: Bool)
    
    func navigateToNDialogue()
    
    func clearSearchBar()
}

protocol SelectUsersPresenterProtocol: BasePresenterProtocol {

    var viewMode: ViewMode? { get set }

    var isMachProfileSelected: Bool { get set }

    func setView(view: SelectUsersViewProtocol)

    func getSelectedUsers() -> [SelectUserViewModel]

    func contactsPermissionAccepted()

    func contactsPermissionRejected()

    func backButtonPressed()
    // User Table
    func loadUsers()

    func getUser(for indexPath: IndexPath) -> SelectUserViewModel?

    func inputSearchText(_ searchText: String)

    func searchButtonClicked()

    func getNumberOfUsersForSection(_ section: Int) -> Int

    func getNumberOfSections() -> Int

    func getTitleForUserSection(_ section: Int) -> String

    func getUserIndexTitles() -> [String]?

    func getSectionForIndexTitle(_ title: String) -> Int

    // Selected Users View
    func getSelectedUser(for index: IndexPath) -> SelectUserViewModel?

    func userSelected(at index: IndexPath)

    func selectedUserRemoved(at index: IndexPath)

    func setTransactionMode(_ transactionMode: TransactionMode?)

    func continueButtonPressed()

    func bluetoothButtonPressed()

    func locationPermissionAccepted()

    func locationPermissionRejected()

    func isNearContactsEnabled() -> Bool

    func isFilterEnabled() -> Bool

    func initializeBluetooth()

    func getSelectedUsersCount() -> Int

    func getSelectedUsersAmountViewModel() -> [UserAmountViewModel]?

    func sendInvitationToNonMachUser()
    
    func viewDidLoad()
}

protocol SelectUsersRepositoryProtocol {

    func getUsers(onSuccess: @escaping (Results<User>) -> Void, onFailure: @escaping (ApiError) -> Void)

    func getUsersBy(deviceBeacons: [DeviceBeacon], onSuccess: @escaping ([User]) -> Void, onFailure: @escaping (ApiError) -> Void)

    func getUserBy(deviceBeacon: DeviceBeacon, onSuccess: @escaping (User) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum SelectUsersError: Error {
    case failed(message: String)
}

class SelectUsersErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
