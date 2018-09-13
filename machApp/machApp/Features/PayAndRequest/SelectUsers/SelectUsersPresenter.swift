//
//  SelectUsersPresenter.swift
//  machApp
//
//  Created by lukas burns on 3/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Contacts
import RealmSwift
import Branch

// swiftlint:disable type_body_length
class SelectUsersPresenter: SelectUsersPresenterProtocol {

    private var branchGeneratedLink: String?

    weak var view: SelectUsersViewProtocol?
    var viewMode: ViewMode? {
        didSet {
            if let viewMode = viewMode {
                switch viewMode {
                case .chargeMach:
                    view?.updateChargeMachTeamView()
                default:
                    break
                }
            }
        }
    }

    var repository: SelectUsersRepositoryProtocol?
    var isMachProfileSelected: Bool = false {
        didSet {
            view?.updateSelectedUsers()
            if isMachProfileSelected {
                view?.showUsersSelectedView()
                view?.showNumberOfSelectedUsersLabel(numberOfSelectedUsers: 1)
                view?.showContinueButton()
            } else {
                view?.hideUsersSelectedView()
                view?.hideNumberOfSelectedUsersLabel()
                view?.hideContinueButton()
            }
            view?.showContinueTooltip(with: !isMachProfileSelected)
        }
    }

    lazy var machProfile: SelectUserViewModel? = {
        guard let machProfile = ConfigurationManager.sharedInstance.getMachTeamConfiguration() else { return nil }
        return SelectUserViewModel(user: User(firstName: machProfile.name, identifier: machProfile.machId, smallImage: machProfile.smallImageURLString))
    }()

    var notificationToken: NotificationToken?
    var users: [SelectUserViewModel] = []
    var selectedUsers: [SelectUserViewModel] = []
    var usersDictionary: [String: [SelectUserViewModel]] = [:]
    var filteredUsersDictionary: [String: [SelectUserViewModel]] = [:]
    var filteredUsersSectionTitles: [String] = []
    var filteredUserIndexTitles: [String] = []
    var nearUsers: [SelectUserViewModel] = []
    var usersSectionTitles: [String] = []
    var userIndexTitles: [String] = []
    var transactionMode: TransactionMode?
    var permissionManager: PermissionManager
    var isBluetoothEnabled: Bool
    var isTextFilterEnabled: Bool

    var maxSelecteableUsers: Int

    required init(repository: SelectUsersRepositoryProtocol?, permissionManager: PermissionManager) {
        self.repository = repository
        self.permissionManager = permissionManager
        isBluetoothEnabled = false
        isTextFilterEnabled = false
        self.branchGeneratedLink = BranchIOManager.sharedInstance.getUrl()
        let config = ConfigurationManager.sharedInstance.getMachTeamConfiguration()
        self.maxSelecteableUsers = config?.maxContactsForGroup ?? 15
    }

    func setView(view: SelectUsersViewProtocol) {
        self.view = view
    }

    func setTransactionMode(_ transactionMode: TransactionMode?) {
        self.transactionMode = transactionMode
        guard let transactionMode = transactionMode else { return }
        switch transactionMode {
        case .payment:
            self.view?.setPaymentTitle()
        case .request:
            self.view?.setRequestTitle()
            self.presentNChargeDialogueIfNecessary()
        default:
            break
        }
    }

    private func presentNChargeDialogueIfNecessary() {
        if !AccountManager.sharedInstance.getHideRequestNDialogue() && self.self.permissionManager.isContactsPermissionGranted() {
            AccountManager.sharedInstance.set(hideRequestNDialogue: true)
            self.view?.navigateToNDialogue()
        }
    }

    func loadUsers() {
        self.createUserDict()
        registerRealmChanges()
        if permissionManager.isContactsPermissionGranted() {
            ContactManager.sharedInstance.syncContacts()
        } else {
            self.view?.askForContactsPermission()
        }
    }

    private func createUserDict() {
        userIndexTitles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]
        usersSectionTitles = userIndexTitles
        usersSectionTitles.insert("Cercanos", at: 0)

        usersDictionary = [:]
        usersDictionary["Cercanos"] = []
        for indexTitle in userIndexTitles {
            usersDictionary[indexTitle] = []
        }

        filteredUsersDictionary = ["Resultados": []]
        filteredUsersSectionTitles = ["Resultados"]
        filteredUserIndexTitles = []

    }

    private func showInviteUsers(with list: Results<User>) {
        if let viewMode = viewMode {
            switch viewMode {
            case .normalTransaction:
                if let configuration = ConfigurationManager.sharedInstance.getMachTeamConfiguration()?.maxContactsToTriggerInvitation {
                    let filteredUsersCount = list.filter("machId != null").count
                    view?.shouldPresentInviteUsersView(with: filteredUsersCount > configuration)
                }
            default:
                break
            }
        }
    }

    private func registerRealmChanges() {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let realmUsers = realm.objects(User.self).filter("isInContacts = %@ AND machId != %@", true, AccountManager.sharedInstance.getMachId() ?? "")
            showInviteUsers(with: realmUsers)
            notificationToken = realmUsers.observe { [weak self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    let initialUsers = realmUsers.map({ (user) -> SelectUserViewModel in
                        return SelectUserViewModel(user: user)
                    })
                    for user in initialUsers {
                        self?.users.append(user)
                        _ = self?.addUserToDictionary(user: user)
                    }
                    self?.view?.updateUsers()
                    break
                case .update(_, _, let insertions, let modifications):
                    if !insertions.isEmpty {
                        var insertedUsersIndexPaths: [IndexPath] = []
                        let insertedUsers = insertions.map({ (index) -> SelectUserViewModel in
                            return SelectUserViewModel(user: realmUsers[index])
                        })
                        for insertedUser in insertedUsers {
                            self?.users.append(insertedUser)
                            let indexPathOfInsertedUser = self?.addUserToDictionary(user: insertedUser)
                            insertedUsersIndexPaths.append(indexPathOfInsertedUser!)
                        }
                        if !(self?.isTextFilterEnabled)! {
                            self?.view?.insertUsers(at: insertedUsersIndexPaths)
                        }
                    }
                    if !modifications.isEmpty {
                        var modifiedUsersIndexPaths: [IndexPath] = []
                        for modifiedUserIndex in modifications {
                            if let modifiedUser = self?.users.get(at: modifiedUserIndex), let indexPath = self?.getIndexPathForUser(user: modifiedUser){
                                modifiedUsersIndexPaths.append(indexPath)
                            }
                        }
                        if !(self?.isTextFilterEnabled)! {
                            self?.view?.updateUsers(at: modifiedUsersIndexPaths)
                        }
                    }
                    break
                case .error(let error):
                    print(error)
                }
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    private func addUserToDictionary(user: SelectUserViewModel) -> IndexPath {
        let sortOrder = CNContactsUserDefaults.shared().sortOrder
        var userKey = "#"
        if sortOrder == .familyName || sortOrder == .none || sortOrder == .userDefault {
            userKey = user.phoneLastName.firstLetter() ?? user.phoneFirstName.firstLetter() ?? "#"
        } else {
            userKey = user.phoneFirstName.firstLetter() ?? user.phoneLastName.firstLetter() ?? "#"
        }
        if !usersDictionary.has(userKey) {
            userKey = "#"
        }
        usersDictionary[userKey]?.append(user)
        let section = usersSectionTitles.index(of: userKey)
        let row = (usersDictionary[userKey]?.count)! - 1
        return IndexPath(row: row, section: section!)
    }
    
    private func getIndexPathForUser(user: SelectUserViewModel) -> IndexPath? {
        for key in usersDictionary.keys {
            for selectUserViewModel in usersDictionary[key] ?? [] {
                if selectUserViewModel.phone == user.phone {
                    let section = usersSectionTitles.index(of: key)
                    let row = (usersDictionary[key]?.count)! - 1
                    return IndexPath(row: row, section: section!)
                }
            }
        }
        return nil
    }

    func contactsPermissionAccepted() {
        permissionManager.askFor(permission: .contacts, onComplete: { (isGranted) in
            if isGranted {
                DispatchQueue.main.async {
                    ContactManager.sharedInstance.syncContacts()
                    self.view?.removeAskForPermissionView()
                }
            } else {
                self.permissionManager.openSettings()
            }
        })
    }

    func contactsPermissionRejected() {
        self.view?.goBackToHome()
    }

    func getUser(for indexPath: IndexPath) -> SelectUserViewModel? {
        if !isTextFilterEnabled {
            guard let sectionKey = usersSectionTitles.get(at: indexPath.section) else { return nil }
            return usersDictionary[sectionKey]?[indexPath.row] ?? nil
        } else {
            guard let sectionKey = filteredUsersSectionTitles.get(at: indexPath.section) else { return nil }
            return filteredUsersDictionary[sectionKey]?[indexPath.row] ?? nil
        }
    }

    func getSelectedUsers() -> [SelectUserViewModel] {
        if let viewMode = viewMode {
            switch viewMode {
            case .chargeMach:
                guard let machProfile = machProfile else {
                    fatalError("At this point of the execution a mach profile should've been created")
                }
                return [machProfile]
            default:
                return selectedUsers
            }
        }
        return []
    }

    func getSelectedUsersAmountViewModel() -> [UserAmountViewModel]? {
        let response = getSelectedUsers().map { (user) -> UserAmountViewModel in
            let userAmountViewModel = UserAmountViewModel(user: user.user)
            userAmountViewModel.isNear = user.isNear
            if let viewMode = viewMode {
                switch viewMode {
                case .chargeMach:
                    if  let machProfile = ConfigurationManager.sharedInstance.getMachTeamConfiguration() {
                        userAmountViewModel.maximumAmount = machProfile.maxOnboardingRequestAmount
                    }
                default:
                    break
                }
            }
            return userAmountViewModel
        }
        return response
    }

    func getSelectedUsersCount() -> Int {
        guard let viewMode = viewMode else { return 0 }
        switch viewMode {
        case .chargeMach:
            return isMachProfileSelected ? 1 : 0
        default:
            return selectedUsers.count
        }
    }

    func getNumberOfUsersForSection(_ section: Int) -> Int {
        if !isTextFilterEnabled {
            guard let sectionKey = usersSectionTitles.get(at: section) else {
                return 0
            }
            guard let users = usersDictionary[sectionKey] else {
                return 0
            }
            return users.count
        } else {
            guard let sectionKey = filteredUsersSectionTitles.get(at: section) else {
                return 0
            }
            guard let users = filteredUsersDictionary[sectionKey] else {
                return 0
            }
            return users.count
        }
    }

    func getNumberOfSections() -> Int {
        if !isTextFilterEnabled {
            return self.usersSectionTitles.count
        } else {
            return self.filteredUsersSectionTitles.count
        }
    }

    func getTitleForUserSection(_ section: Int) -> String {
        if !isTextFilterEnabled {
            return usersSectionTitles[section]
        } else {
            return filteredUsersSectionTitles[section]
        }
    }

    func getUserIndexTitles() -> [String]? {
        if !isTextFilterEnabled {
            return userIndexTitles
        } else {
            return filteredUserIndexTitles
        }
    }

    func getSectionForIndexTitle(_ title: String) -> Int {
        if !isTextFilterEnabled {
            guard let index = usersSectionTitles.index(of: title) else {
                return -1
            }
            return index
        } else {
            return 0
        }
    }

    func getSelectedUser(for index: IndexPath) -> SelectUserViewModel? {
        guard let viewMode = viewMode else { fatalError("no view mode set") }
        switch  viewMode {
        case .chargeMach:
            return machProfile
        default:
            return selectedUsers[index.row]
        }
    }

    func userSelected(at index: IndexPath) {
        guard let selectedUser = getUser(for: index), let transactionMode = transactionMode else { return }
        view?.clearSearchBar()
        
        if selectedUser.isMach {
            if selectedUser.isSelected {
                selectedUser.isSelected = false
                if let index = selectedUsers.index(where: { $0 == selectedUser }) {
                    selectedUsers.remove(at: index)
                }
            } else {
                switch transactionMode {
                case .request:
                    if selectedUsers.count > self.maxSelecteableUsers - 1 {
                        self.view?.showIncorrectNumberOfUsersError()
                        return
                    }
                case .payment:
                    if selectedUsers.count == 1 {
                        self.view?.showIncorrectNumberOfUsersError(maxSelecteableUsers: 1)
                        return
                    }
                default:
                    return
                }
                selectedUser.isSelected = true
                selectedUsers.insert(selectedUser, at: 0)
            }
            updateUserViews()
        } else {
            guard let machUrl = URL(string: branchGeneratedLink!) else { return }
            let name = (
                selectedUser.firstNameToShow + " " + selectedUser.lastNameToShow
            ).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let phoneNumber = "+\(selectedUser.phone)"
            var stURL = ""
            switch transactionMode {
            case .payment:
                stURL = "whatsapp://send?phone=\(phoneNumber)&text=Ey, te quiero pagar las lucas que te debo, bájate MACH, la app de pagos sin datos bancarios, y te pago por ahí más fácil. \(machUrl.absoluteString)"
                SegmentAnalytics.Event.invitationSent(
                    location: SegmentAnalytics.EventParameter.InvitationType().payment,
                    contact_phone: phoneNumber,
                    contact_name: name
                    ).track()
            case .request:
                 stURL = "whatsapp://send?phone=\(phoneNumber)&text= Hola! Acuérdate que me que me debes lucas. Bájate MACH en \(machUrl.absoluteString) y págame por ahí."
                 SegmentAnalytics.Event.invitationSent(
                    location: SegmentAnalytics.EventParameter.InvitationType().request,
                    contact_phone: phoneNumber,
                    contact_name: name
                    ).track()
            default:
                return
            }
            guard let urlString = stURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed), let url = URL.init(string: urlString) else { return }
            view?.inviteANonMachUser(with: url, text: "No pierdas tiempo, invita a \(name) a MACH a través de whatsapp")
        }
    }

    func selectedUserRemoved(at index: IndexPath) {
        guard let viewMode = viewMode else { fatalError("no view mode set") }
        switch  viewMode {
        case .chargeMach:
             isMachProfileSelected = false
        default:
            guard let user = selectedUsers.get(at: index.row) else {
                return
            }
            user.isSelected = false
            selectedUsers.remove(at: index.row)
            updateUserViews()
        }
    }

    private func updateUserViews() {
        if selectedUsers.isEmpty {
            self.view?.hideUsersSelectedView()
            self.view?.hideContinueButton()
            self.view?.hideNumberOfSelectedUsersLabel()
        } else {
            self.view?.showUsersSelectedView()
            self.view?.showContinueButton()
            self.view?.showNumberOfSelectedUsersLabel(numberOfSelectedUsers: self.selectedUsers.count)
        }
        self.view?.updateUsers()
        self.view?.updateSelectedUsers()
    }

    // MARK: - Filter Contact functions

    func isFilterEnabled() -> Bool {
        return isTextFilterEnabled
    }

    func inputSearchText(_ searchText: String) {
        self.view?.removePlaceholder()
        if searchText.isBlank {
            isTextFilterEnabled = false
        } else {
            let filteredUsers = filter(by: searchText)
            filteredUsersDictionary = ["Resultados": filteredUsers]
            if filteredUsers.isEmpty {
                self.view?.insertPlaceholder()
            }
            isTextFilterEnabled = true
        }
        self.view?.updateUsers()
    }

    func searchButtonClicked() {
        self.view?.searchBarResignFirstResponder()
    }

    private func filter(by searchText: String) -> [SelectUserViewModel] {
        let filteredUsers = users.filter({ (user) -> Bool in
            let firstName = user.phoneFirstName.lowercased()
            let lastName = user.phoneLastName.lowercased()
            let searchText = searchText.lowercased()
            let names = (firstName + " " + lastName).split(" ")
            for name in names {
                if name.hasPrefix(searchText) {
                    return true
                }
            }
            if firstName.hasPrefix(searchText) || lastName.hasPrefix(searchText) || (firstName + " " + lastName).hasPrefix(searchText) {
                return true
            }
            return false
        })
        let nearByFilteredUsers = nearUsers.filter({ (user) -> Bool in
            let firstName = user.machFirstName.lowercased()
            let lastName = user.machLastName.lowercased()
            let searchText = searchText.lowercased()
            let names = (firstName + " " + lastName).split(" ")
            for name in names {
                if name.hasPrefix(searchText) {
                    return true
                }
            }
            if firstName.hasPrefix(searchText) || lastName.hasPrefix(searchText) || (firstName + " " + lastName).hasPrefix(searchText) {
                return true
            }
            return false
        })
        return nearByFilteredUsers + filteredUsers
    }

    func continueButtonPressed() {
        if let viewMode = viewMode {
            switch viewMode {
            case .chargeMach:
                self.view?.navigateToSelectAmount()
            default:
                if let selectedUser = selectedUsers.first, selectedUser.isMach {
                    self.view?.navigateToSelectAmount()
                    trackStartedFlow(isNear: selectedUser.isNear)
                } else {
                    self.view?.showNonMachUserError()
                }
            }
        }
    }

    private func trackStartedFlow(isNear: Bool){
        guard let transactionMode = transactionMode else { return }
        switch transactionMode {
        case .payment:
            if isNear{
                SegmentAnalytics.Event.paymentFlowStarted(location: SegmentAnalytics.EventParameter.LocationType().navbar, method: SegmentAnalytics.EventParameter.PhoneMethod().contact).track()
            }else{
                 SegmentAnalytics.Event.paymentFlowStarted(location: SegmentAnalytics.EventParameter.LocationType().navbar, method: SegmentAnalytics.EventParameter.PhoneMethod().bluetooth).track()
            }
        case .request:
            if isNear{
                 SegmentAnalytics.Event.requestFlowStarted(location: SegmentAnalytics.EventParameter.LocationType().navbar, method: SegmentAnalytics.EventParameter.PhoneMethod().contact).track()
            }else{
                 SegmentAnalytics.Event.requestFlowStarted(location: SegmentAnalytics.EventParameter.LocationType().navbar, method: SegmentAnalytics.EventParameter.PhoneMethod().bluetooth).track()
            }
        default:
            break
        }
    }

    func backButtonPressed() {
        guard let transactionMode = transactionMode else {
            self.view?.goBackToHome()
            return
        }
        guard !selectedUsers.isEmpty else {
            self.view?.goBackToHome()
            return
        }

        switch transactionMode {
        case .payment:
            self.view?.showConfirmationAlert(title: "Estas seguro", message: "Deseas descartar el pago?", onAccepted: {
                self.view?.goBackToHome()
            }, onCancelled: {
                //do nothing
            })
        case .request:
            self.view?.showConfirmationAlert(title: "Estas seguro", message: "Deseas descartar el cobro?", onAccepted: {
                self.view?.goBackToHome()
            }, onCancelled: {
                //do nothing
            })
        default:
            break
        }
    }

    func sendInvitationToNonMachUser() {
        let tuple = createInviteActivity()

        SegmentAnalytics.Event.invitationSent(
            location: SegmentAnalytics.EventParameter.InvitationType().contact_menu,
            contact_phone: nil,
            contact_name: nil
            ).track()

        view?.inviteNonMachFriends(withString: "", url: tuple.0, excludedTypes: tuple.1)
    }

    private func createInviteActivity() -> (URL, [UIActivityType]) {
        //swiftlint:disable:next force_unwrapping
        let machUrl: URL = URL(string: self.branchGeneratedLink!)!
        let excludedTypes: [UIActivityType] = [.postToWeibo, .print, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .airDrop]
        return (machUrl, excludedTypes)
    }

    // MARK: - Near Section Fucntions

    internal func initializeBluetooth() {
        guard permissionManager.isGranted(permission: Permission.locationServices) else {
            if isBluetoothEnabled {
                self.isBluetoothEnabled = false
                self.view?.showBluetoothButtonDisabled()
            }
            return
        }
        if BluetoothManager.sharedInstance.isBluetoothOn() {
            self.isBluetoothEnabled = true
            self.view?.showBluetoothButtonEnabled()
            BluetoothManager.sharedInstance.delegate = self
        } else {
            self.isBluetoothEnabled = false
            self.view?.showBluetoothButtonDisabled()
        }
    }

    func locationPermissionAccepted() {
        permissionManager.askFor(permission: .locationServices, onComplete: handleLocationPermission)
    }

    func handleLocationPermission(isGranted: Bool) {
        if isGranted {
            self.view?.hideAskForLocationView()
            if !isBluetoothEnabled {
                bluetoothButtonPressed()
            }
        } else {
            self.permissionManager.openSettings()
        }
    }

    func locationPermissionRejected() {
        self.view?.hideAskForLocationView()
    }

    func bluetoothButtonPressed() {
        if permissionManager.isLocationServicesPermissionGranted() {
            isBluetoothEnabled = !isBluetoothEnabled
            if isBluetoothEnabled {
                startBluetoothFunction()
            } else {
                stopBluetoothFunction()
            }
        } else {
            self.view?.askForLocationServicePermission()
        }
    }

    private func startBluetoothFunction() {
        self.view?.showBluetoothButtonEnabled()
        BluetoothManager.sharedInstance.delegate = self
        if let minor = AccountManager.sharedInstance.getUser()?.deviceBeacon?.minor, let major = AccountManager.sharedInstance.getUser()?.deviceBeacon?.major {
            BluetoothManager.sharedInstance.initLocalBeacon(minor: UInt16(minor), major: UInt16(major))
        }
        BluetoothManager.sharedInstance.startLoactingBeacons()
        self.view?.reloadNearUsersSection()
    }

    private func stopBluetoothFunction() {
        self.view?.showBluetoothButtonDisabled()
        BluetoothManager.sharedInstance.stopLocalBeacon()
        BluetoothManager.sharedInstance.stopLoactingBeacons()
        let nearSection = usersSectionTitles[0]
        usersDictionary[nearSection]? = []
        nearUsers = []
        self.view?.reloadNearUsersSection()
        removeNearSelectedUsers()
    }

    func removeNearSelectedUsers() {
        var nearSelectedUsers: [SelectUserViewModel] = []
        for selectedUser in selectedUsers {
            if selectedUser.isNear {
                nearSelectedUsers.append(selectedUser)
            }
        }
        for nearSelectedUser in nearSelectedUsers {
            selectedUsers.removeFirst(nearSelectedUser)
        }
        self.updateUserViews()
    }

    func isNearContactsEnabled() -> Bool {
        return isBluetoothEnabled
    }

    func removeNearUsersNotFound(devicesBeacons: [DeviceBeacon]) {
        for user in nearUsers {
            var isUserNear = false
            for deviceBeacon in devicesBeacons {
                if user.major == deviceBeacon.major && user.minor == deviceBeacon.minor {
                    isUserNear = true
                    user.wasFoundNear(isFound: true)
                }
            }
            if !isUserNear && !user.isSelected {
                user.wasFoundNear(isFound: false)
                if user.shouldRemoveFromNearUsers() {
                    removeNearUser(user: user)
                }
            }
        }
    }

    private func removeNearUser(user: SelectUserViewModel) {
        let nearSection = usersSectionTitles[0]
        guard let indexOfUserToRemove = usersDictionary[nearSection]?.index(of: user) else { return }
        usersDictionary[nearSection]?.remove(at: indexOfUserToRemove)
        self.view?.removeUser(at: indexOfUserToRemove)
        nearUsers.removeFirst(user)
        if (usersDictionary[nearSection]?.isEmpty)! {
            self.view?.reloadNearUsersSection()
        }
    }

    // Checks if user is not added and Calls Repository to get by minor and major to add it
    internal func nearUsersFound(devicesBeacons: [DeviceBeacon]) {
        for deviceBeacons in devicesBeacons {
            var isUserAdded = false
            for user in nearUsers {
                if deviceBeacons.minor == user.minor && deviceBeacons.major == user.major {
                    isUserAdded = true
                }
            }
            if !isUserAdded {
                self.repository?.getUsersBy(deviceBeacons: [deviceBeacons], onSuccess: { (users) in
                    for user in users {
                        let userViewModel = SelectUserViewModel(user: user)
                        userViewModel.isNear = true
                        self.addNearUser(user: userViewModel)
                    }
                }, onFailure: { (error) in
                    self.handle(error: error)
                })
            }
        }
    }

    // Adds a near user to the near users section if it was not added before
    private func addNearUser(user: SelectUserViewModel) {
        for nearUser in nearUsers {
            if nearUser.minor == user.minor && nearUser.major == user.major {
                return
            }
        }
        guard let nearSection = usersSectionTitles.get(at: 0) else { return }
        usersDictionary[nearSection]?.append(user)
        nearUsers.append(user)
        if isTextFilterEnabled {
            self.view?.insertUser(at: 0)
        } else {
            if let lastNearUserIndex = (usersDictionary[nearSection]?.count) {
                self.view?.insertUser(at: lastNearUserIndex - 1)
            }
        }
        self.view?.reloadNearUsersSection()
    }

    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError():
            self.view?.showNoInternetConnectionError()
        case .serverError(let selectUserError):
            guard let selectUserError = selectUserError as? SelectUsersError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch selectUserError {
            case .failed( _):
                break
            }
        case .clientError(let selectUserError):
            guard let selectUserError = selectUserError as? SelectUsersError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch selectUserError {
            case .failed( _):
                break
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
    
    func viewDidLoad(){
         SegmentAnalytics.Event.cashOutMenuAccessed(location: SegmentAnalytics.EventParameter.LocationType().navbar).track()
    }
}

extension SelectUsersPresenter: BluetoothManagerDelegate {

    func didFoundBeaconWith(major: UInt16, minor: UInt16) {

    }

    func didFoundBeacons(devicesBeacons: [DeviceBeacon]) {
        removeNearUsersNotFound(devicesBeacons: devicesBeacons)
        nearUsersFound(devicesBeacons: devicesBeacons)
    }
}
