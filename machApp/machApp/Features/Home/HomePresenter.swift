//
//  HomePresenter.swift
//  machApp
//
//  Created by lukas burns on 3/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class HomePresenter: HomePresenterProtocol {

    static let failureTimerLapse = 60
    //Make sure the timer lapse is greater than the animation on the view controller
    static let balanceAnimationTimerLapse = Int((Constants.AnimationConstants.HomeViewController.balanceAnimationDuration + Constants.AnimationConstants.HomeViewController.balanceAnimationDelay).rounded(.up))

    weak var view: HomeViewProtocol?
    var transactionViewModel: TransactionViewModel?
    var repository: HomeRepositoryProtocol?

    var groupNotificationToken: NotificationToken?
    var balanceNotificationToken: NotificationToken?

    var historyGroupsViewModels: [GroupViewModel] = []
    var isGroupHistoryComplete: Bool
    var permissionManager: PermissionManager
    var isBluetoothEnabled: Bool

    //The only way this timer could be stopped is if the seconds variable reaches 0 or if the getBalance func returns success.
    var failureTimer: Timer = Timer()
    var failureTimerSeconds: Int = failureTimerLapse
    var isFailureTimerRunning: Bool = false
    var balanceRequestCount: Int = 0

    var balanceAnimationTimer = Timer()
    var balanceAnimationTimerSeconds = balanceAnimationTimerLapse
    var isBalanceAnimationTimerRunning: Bool = false

    required init(repository: HomeRepositoryProtocol?, permissionManager: PermissionManager) {
        self.repository = repository
        self.isGroupHistoryComplete = false
        self.permissionManager = permissionManager
        self.isBluetoothEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(HomePresenter.refreshBalance), name: .DidReceiveTransaction, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomePresenter.didUpdateProfile), name: .ProfileDidUpdate, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup() {
        self.loadGroups()
        self.getMachTeamProfile()
        NotificationManager.sharedInstance.startListeningForMessages()
        NotificationCenter.default.addObserver(self, selector: #selector(userDataDeleted), name: .UserDataDeleted, object: nil)
    }
    
    @objc private func userDataDeleted() {
        self.groupNotificationToken?.invalidate()
        self.balanceNotificationToken?.invalidate()
    }

    func startFailureTimer() {
        balanceRequestCount += 1
        //Make sure I only create one timer
        //If this function is called and a timer is running, I shouldnt create a new one
        if !isFailureTimerRunning {
            failureTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateFailureTimer)), userInfo: nil, repeats: true)
            isFailureTimerRunning = true
        } else {
            if balanceRequestCount == 4 {
                //Present toast view in VC
                self.view?.showUpdateBalanceFailure()
                restartFailureTimer()
            }
        }
    }

    func startUpdateBalanceAnimationTimer() {
        balanceAnimationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateBalanceAnimationTimer)), userInfo: nil, repeats: true)
        isBalanceAnimationTimerRunning = true
    }

    @objc func updateBalanceAnimationTimer() {
        balanceAnimationTimerSeconds -= 1
        if balanceAnimationTimerSeconds <= 0 {
            restartBalanceUpdateAnimationTimer()
        }
    }

    @objc func updateFailureTimer() {
        //Decrease seconds count
        failureTimerSeconds -= 1
        //If the timer passes through this if, that means the repository was not able to retrieve the balance in 60 seconds.
        if failureTimerSeconds <= 0 {
            //Stop timer and restart seconds count
            restartFailureTimer()
        }
    }

    func setView(view: HomeViewProtocol) {
        self.view = view
    }

    func initializeBluetooth() {
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
        } else {
            self.isBluetoothEnabled = false
            self.view?.showBluetoothButtonDisabled()
        }
    }

    internal func loadGroups() {
        registerRealmChanges()
    }

    internal func getHistory() {
        repository?.getHistory(onSuccess: {[weak self] (groups) in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.historyGroupsViewModels = groups.map({ (group) -> GroupViewModel in
                return GroupViewModel(group: group)
            })
            if unwrappedSelf.historyGroupsViewModels.isEmpty {
                unwrappedSelf.getLastGroups()
            } else {
                unwrappedSelf.view?.stopRefreshControl()
                unwrappedSelf.view?.updateHistory()
            }
            }, onFailure: { (historyError) in
                self.handle(error: historyError)
        })
    }

    internal func createOnboardingTooltip() -> UIView? {
        //If wasTabBarTooltipShown == false && BCI payed the user's request, that means the tooltip has not been shown yet.
        guard let config = ConfigurationManager.sharedInstance.getMachTeamConfiguration(), !config.wasTabBarTooltipShown, config.wasChargeAccepted else { return nil }
        //Tooltip label
        let tooltipLabel = UILabel()
        tooltipLabel.translatesAutoresizingMaskIntoConstraints = false
        tooltipLabel.text = "Ahora puedes pagarle a un amigo"
        //swiftlint:disable:next force_unwrapping
        tooltipLabel.font = UIFont (name: "Nunito-Regular", size: 15)!
        tooltipLabel.numberOfLines = 1
        tooltipLabel.textAlignment = .center
        tooltipLabel.textColor = .white
        tooltipLabel.adjustsFontSizeToFitWidth = true

        //Tooltip view
        let tooltip = BaseTooltipView()
        tooltip.translatesAutoresizingMaskIntoConstraints = false
        tooltip.fillColor = Color.aquamarine
        tooltip.borderRadius = 5
        tooltip.shadowBlur = 5.0
        tooltip.shadowOffsetX = 0.7
        tooltip.shadowOffsetY = 0.7
        tooltip.shadowColor = UIColor.init(r: 0.0, g: 0.0, b: 0.0, a: 0.5)
        tooltip.backgroundColor = .clear
        tooltip.arrowBottomCenter = true
        tooltip.addSubview(tooltipLabel)

        //Label autolayout
        tooltipLabel.bottomAnchor.constraint(equalTo: tooltip.bottomAnchor, constant: -20.0).isActive = true
        tooltipLabel.topAnchor.constraint(equalTo: tooltip.topAnchor, constant: 20).isActive = true
        tooltipLabel.leadingAnchor.constraint(equalTo: tooltip.leadingAnchor, constant: 20).isActive = true
        tooltipLabel.trailingAnchor.constraint(equalTo: tooltip.trailingAnchor, constant: -20).isActive = true
        tooltipLabel.layoutIfNeeded()

        return tooltip
    }

    internal func getBalance(triggeredByUser: Bool) {
        if transactionViewModel == nil {
            startFailureTimer()
            repository?.getSavedBalance(response: {[weak self] (balance) in
                //If a timer is running (that means a balance )
                if let unwrappedBalance = balance, let unwrappedSelf = self, unwrappedSelf.isBalanceAnimationTimerRunning == false {
                    unwrappedSelf.view?.updateBalance(response: createHomeBalanceResponseWith(balance: unwrappedBalance.balance, date: unwrappedBalance.lastRetrievedDate, source: .device))
                }
            })
            repository?.getBalance(onSuccess: {[weak self] (balance) in
                //Restart timer
                if let unwrappedSelf = self {
                    unwrappedSelf.restartFailureTimer()
                    unwrappedSelf.view?.stopRefreshControl()
                    /*
                     Start a timer that lasts the time the animation takes, so that in case that this function is called again but the view controller is still animating,
                     do not call the update function again
                     */
                    if !unwrappedSelf.isBalanceAnimationTimerRunning {
                        unwrappedSelf.startUpdateBalanceAnimationTimer()
                        unwrappedSelf.view?.updateBalance(response: unwrappedSelf.createHomeBalanceResponseWith(balance: balance.balance, date: balance.lastRetrievedDate, source: .endpoint))
                    }
                }
                }, onFailure: {[weak self] (balanceError) in
                    self?.view?.stopRefreshControl()
                    self?.handle(error: balanceError, showDefaultError: triggeredByUser)
            })
        }
    }

    internal func getNumberOfGroups() -> Int {
        return historyGroupsViewModels.count
    }

    internal func getGroup(at indexPath: IndexPath) -> GroupViewModel {
        return historyGroupsViewModels[indexPath.row]
    }

    internal func areThereTransactions() -> Bool {
        return historyGroupsViewModels.reduce(false, {
            return $0 || $1.isTransactionsPopulated()
        })
    }

    internal func pullToRefresh() {
        Thread.runOnMainQueue(1.5) {[weak self] in
            self?.getBalance(triggeredByUser: true)
        }
    }

    internal func getMachTeamProfile() {
        repository?.getMachTeamProfile(onSuccess: {[weak self] in
    
        }, onFailure: {})
    }

    internal func getSignupDate() {
        repository?.fetchSignupDate()
    }

    func getGroup(for chatMessage: ChatMessageBaseViewModel) -> GroupViewModel? {
        return historyGroupsViewModels.first(where: { (groupViewModel) -> Bool in
            if let groupId = groupViewModel.group?.identifier, let chatMessageGroupId = chatMessage.groupId, groupId == chatMessageGroupId {
                return true
            } else {
                return false
            }
        })
    }

    func userScrolledToLastGroup() {
        getLastGroups()
    }

    private func getLastGroups() {
        guard !isGroupHistoryComplete else { return }
        self.view?.showActivityIndicator()
        self.repository?.getGroupsAfter(lastGroup: historyGroupsViewModels.last?.group,
                                        onSuccess: { (transactions) in
                                            var groupIds: [String: String] = [:]
                                            for transaction in transactions {
                                                if let groupId = transaction.groupId, !groupIds.has(groupId) {
                                                    groupIds[groupId] = ""
                                                }
                                            }
                                            if transactions.isEmpty || groupIds.count < 10 {
                                                self.isGroupHistoryComplete = true
                                            }
                                            // Cool Beans
                                            for transaction in transactions {
                                                transaction.seen = true
                                                do {
                                                    try TransactionManager.handleTransactionReceived(transaction: transaction)
                                                } catch {
                                                    ExceptionManager.sharedInstance.recordError(error)
                                                }
                                            }
                                            self.view?.hideActivityIndicator()
        }, onFailure: { (error) in
            self.view?.hideActivityIndicator()
            self.handle(error: error)
        })
    }

    func viewWillDissapear() {
        //If the user goes to other screen, stop the timer
        restartFailureTimer()
        restartBalanceUpdateAnimationTimer()
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

    func updateUserInfo() {
        repository?.getOwnProfile(onSuccess: {[weak self] userProfile in
            self?.saveUser(with: userProfile)
        }, onFailure: { _ in })
    }
    
    func historyTapped() {
        view?.navigateToHistory()
        SegmentAnalytics.Event.historyAccessed(location: SegmentAnalytics.EventParameter.LocationType().home).track()
    }
    
    func getAccountState() {
        guard let rep = repository else { return }
        let mailState = rep.isUsersMailValidated()
        
        //We need to combine both states because the badge has to be shown if either of them is false
        if mailState {
            view?.updateMoreBadge(with: true)
        } else {
            view?.updateMoreBadge(with: false)
        }
    }
    
    // MARK: - Profile updated notification handlers
    @objc func didUpdateProfile() {
        getAccountState()
    }


    // MARK: - Private
    private func restartFailureTimer() {
        failureTimer.invalidate()
        failureTimerSeconds = HomePresenter.failureTimerLapse
        isFailureTimerRunning = false
        balanceRequestCount = 0
    }
    
    private func restartBalanceUpdateAnimationTimer() {
        balanceAnimationTimer.invalidate()
        balanceAnimationTimerSeconds = HomePresenter.balanceAnimationTimerLapse
        isBalanceAnimationTimerRunning = false
    }
    
    private func registerRealmChanges() {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            groupNotificationToken = realm.objects(Group.self).observe { [weak self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial, .update:
                    self?.getHistory()
                    break
                case .error(let error):
                    print(error)
                    break
                }
            }
            balanceNotificationToken = realm.objects(Balance.self).observe({ (changes: RealmCollectionChange) in
                switch changes {
                case .initial(let results), .update(let results, _, _, _):
                    if let _ = results.first {}
                    break
                case .error:
                    break
                }
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }
    
    
    
    private func startBluetoothFunction() {
        self.view?.showBluetoothButtonEnabled()
        if let minor = AccountManager.sharedInstance.getUser()?.deviceBeacon?.minor, let major = AccountManager.sharedInstance.getUser()?.deviceBeacon?.major {
            BluetoothManager.sharedInstance.initLocalBeacon(minor: UInt16(minor), major: UInt16(major))
        }
        BluetoothManager.sharedInstance.startLoactingBeacons()
    }
    
    private func stopBluetoothFunction() {
        self.view?.showBluetoothButtonDisabled()
        BluetoothManager.sharedInstance.stopLocalBeacon()
        BluetoothManager.sharedInstance.stopLoactingBeacons()
    }
    
    private func createHomeBalanceResponseWith(balance: Float, date: Date, source: Source) -> HomeBalanceResponse {
        
        var stringDate: String = ""
        var removeFlag: Bool = false
        
        switch source {
        case .endpoint:
            stringDate = "Actualizado justo ahora"
            removeFlag = true
        case .device:
            removeFlag = false
            let currentDate = Date()
            if !Calendar.current.isDateInToday(date) {
                stringDate = "Actualizado el \(date.getDaysMonthYear())"
            } else if currentDate.minutes(from: date) >= 10 {
                stringDate = "Actualizado a las \(date.getHourAndMinutes())"
            }
        }
        return HomeBalanceResponse(convertedDate: stringDate, convertedBalance: Int(balance).toCurrency(), shouldRemoveDateAfterShown: removeFlag, balance: Int(balance))
    }
    
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError:
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let homeError):
            guard let homeError = homeError as? HomeError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch homeError {
            case .failed:
                break
            default:
                break
            }
        case .clientError(let homeError):
            guard let homeError = homeError as? HomeError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch homeError {
            case .failed:
                break
            default:
                break
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
    
    private func saveUser(with data: UserProfileResponse) {
        let user = User(userProfileResponse: data)
        AccountManager.sharedInstance.saveUser(user: user)
        AccountManager.sharedInstance.setNumberOfPinAttempts(number: 0)
    }
    
    //Selector for .DidReceiveTransactionNotification notification
    @objc func refreshBalance() {
        getBalance(triggeredByUser: false)
    }
}
