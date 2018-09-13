//
//  HomeViewController.swift
//  machApp
//
//  Created by lukas burns on 2/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import Lottie
import EFCountingLabel

class HomeViewController: BaseViewController {

    // MARK: - Constants
    let showChatDetailForNewTransaction: String = "showChatDetailForNewTransaction"
    let cellIdentifier: String = "GroupCell"
    let showChatDetail: String = "showChatDetail"
    let showPrepaidCards: String = "showPrepaidCards"
    let historySegue: String = "historySegue"

    let spinnerLabel: SpinnerView = SpinnerView()
    let spinnerTable: SpinnerView = SpinnerView()
    let refreshControl = UIRefreshControl()

    // MARK: - Outlets
    @IBOutlet weak var balanceHeaderView: UIView!
    @IBOutlet weak var titleHeaderLabel: UILabel!
    @IBOutlet weak var balanceHeaderLabel: EFCountingLabel!
    @IBOutlet weak var bottomHeaderLabel: UILabel!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var bluetoothButton: UIButton!
    @IBOutlet weak var failureToastView: UIView!
    @IBOutlet weak var failureToastViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var balanceStackView: UIStackView!

    @IBOutlet weak var creditCardActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var creditCardButton: UIButton!
    @IBOutlet weak var profileBadge: UIImageView!
    
    // MARK: - Variables
    var presenter: HomePresenterProtocol?
    var newTransactionViewModel: TransactionViewModel? {
        didSet {
            presenter?.transactionViewModel = newTransactionViewModel
        }
    }
    var executeTransactionError: ExecuteTransactionError?
    var tooltip: BaseTooltipView?
    var loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var locationPermissionView: PermissionView?
    var shouldShowSavedAccountSuccesfullyToast: Bool?

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupPresenterAfterViewDidLoad()
        registerPushNotifications()
        initializeLocationPermissionView()
        UIApplication.shared.statusBarStyle = .lightContent
        ConfigurationManager.sharedInstance.getContingencyTokenIfNotExists()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        presenter?.getAccountState()
        if let showAccountToast = shouldShowSavedAccountSuccesfullyToast, showAccountToast {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {[weak self] in
                self?.showSavedAccountToast()
            }
            shouldShowSavedAccountSuccesfullyToast = nil
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.balanceView.setMachGradient()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ConfigurationManager.sharedInstance.switchToContingencyModeIfServersNotResponding()
        setupPresenterAfterViewWillAppear()
        setupToolbar()
        self.hideNavigationBar(animated: true)
        
        navigateToChatDetailAutomatically()
        showTransactionError()
        
        //We call shake button here to ensure we shake the button after card waiting list view is dismissed.
        shakePayMachButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.viewWillDissapear()
        tooltip?.removeSubviews()
        tooltip?.removeFromSuperview()
        tooltip = nil

        //Do not delete this lines. Their purpose is to "stop" the balance animation if it's running and the user leaves this view. 
        balanceStackView?.removeSubviews()
    }

    deinit {
        removeNotificationObserver()
    }

    func setupView() {
        setupTableView()
        setupForceTouch()
        setupBalanceLabel()
        initializeLocationPermissionView()
        setupNotifications()
    }

    func setupToolbar() {
        tooltip = presenter?.createOnboardingTooltip() as? BaseTooltipView
        if let tooltip = tooltip {
            view.addSubview(tooltip)
            tooltip.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            tooltip.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
            tooltip.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
            tooltip.layoutIfNeeded()
        }
    }

    func setupTableViewBackground() {
        if let presenter = presenter {
            if !presenter.areThereTransactions() {
                if let emptyTableView = EmptyTableView.instanceFromNib() {
                    emptyTableView.delegate = self
                    homeTableView.backgroundView = emptyTableView
                    //We call shake button here to ensure we shake the button after card waiting list view is dismissed.
                   emptyTableView.shakeChargeMachButton()
                }
            } else {
                homeTableView.backgroundView = nil
            }
        }
    }

    func initializeLocationPermissionView() {
        locationPermissionView = PermissionView.instanceFromNib(for: .locationServices)
        locationPermissionView?.delegate = self
        locationPermissionView?.frame = self.view.bounds
    }

    private func setupTableView() {
        homeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.homeTableView.tableFooterView = loadingIndicator
        loadingIndicator.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: homeTableView.bounds.width, height: CGFloat(44))
        refreshControl.tintColor = Color.violetBlue
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        homeTableView.addSubview(refreshControl)
    }

    private func setupPresenterAfterViewDidLoad() {
        self.presenter?.setup()
        self.presenter?.loadGroups()
        self.presenter?.getSignupDate()
        self.presenter?.updateUserInfo()
        //Load Mach Team Profile info
        self.presenter?.getMachTeamProfile()
    }

    private func setupForceTouch() {
        if self.isForceTouchAvailable() {
            self.registerForPreviewing(with: self, sourceView: homeTableView)
        }
    }

    private func setupBalanceLabel() {
        balanceHeaderLabel.formatBlock = {
            return Int($0).toCurrency()
        }
    }
    
    private func navigateToChatDetailAutomatically() {
        if presenter?.transactionViewModel != nil {
            self.performSegue(withIdentifier: showChatDetailForNewTransaction, sender: newTransactionViewModel)
        }
    }
    
    private func showTransactionError() {
        if let transactionError = executeTransactionError {
            switch transactionError {
            case .cashoutUnknownState:
                self.showErrorMessage(title: "", message: "Tu retiro está en progreso, verifica tu saldo dentro de 5 minutos", completion: nil)
            default:
                break
            }
            self.executeTransactionError = nil
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default
            .addObserver(self,
                    selector: #selector(self.shakePayMachButton),
                    name: NSNotification.Name(rawValue: Constants.Passcode.correctPasscodeEntered),
                    object: nil)
        NotificationCenter.default
            .addObserver(self,
                    selector: #selector(didSaveAccount),
                    name: .DidSaveAccount,
                    object: nil)
    }
    
    @objc func shakePayMachButton() {
        guard let backgroundView = homeTableView.backgroundView as? EmptyTableView else { return }
        backgroundView.shakeChargeMachButton()
    }

    func registerPushNotifications() {
        //swiftlint:disable:next force_cast
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.registerForPushNotifications(UIApplication.shared)
    }
    
    @objc func didSaveAccount() {
        shouldShowSavedAccountSuccesfullyToast = true
    }

    // MARK: - Actions
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        if segue.source is ExecuteTransactionViewController {
            /* The purpose of this notification is to pop the "More" tab to its root controller.
             Other wise if the user taps there, the first screen will be withdrawTEF */
            NotificationCenter.default.post(name: .DidExecuteTransactionSuccesfully, object: nil)
        } else if segue.source is ExecuteRechargeViewController ||
            segue.source is CreditCardTimeoutViewController ||
            segue.source is CreditCardSuccessRechargeViewController {
            NotificationCenter.default.post(name: .DidExecuteRecharge, object: nil)
        }
        print("Back to Home")
    }
    
    private func showSavedAccountToast() {
        super.showToastWithText(text: "Cuenta de retiro guardada 👍")
    }

    @IBAction func bluetoothButtonActionPressed(_ sender: UIButton) {
        self.presenter?.bluetoothButtonPressed()
    }
    
    @IBAction func didPressHistoryButton(_ sender: Any) {
        presenter?.historyTapped()
    }
    
    private func setupPresenterAfterViewWillAppear() {
        presenter?.getBalance(triggeredByUser: false)
        presenter?.getHistory()
        presenter?.initializeBluetooth()
    }

    fileprivate func createBalanceUpdatedAtLabel(with text: String) -> UILabel {
        let label = UILabel.init(frame: .zero)
        label.text = text
        label.textColor = .white
        //swiftlint:disable:next force_unwrapping
        label.font = UIFont(name: "Nunito-Light", size: 13.0)!
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749.0), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 250.0), for: .horizontal)
        return label
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showChatDetail {
            guard let destinationVC = segue.destination as? ChatDetailViewController else { return }
            guard let indexPath = sender as? IndexPath else { return }
            let groupViewModel = self.presenter?.getGroup(at: indexPath)
            destinationVC.groupViewModel = groupViewModel
        } else if segue.identifier == showChatDetailForNewTransaction {
            guard let destinationVC = segue.destination as? ChatDetailViewController else { return }
            guard let chatMessageBaseViewModel = sender as? ChatMessageBaseViewModel else { return }
            let groupViewModel = self.presenter?.getGroup(for: chatMessageBaseViewModel)
            destinationVC.groupViewModel = groupViewModel
            presenter?.transactionViewModel = nil
        } else if segue.identifier == self.showPrepaidCards, let destinationVC = segue.destination as? PrepaidCardNavigationViewController, let prepaidCards = sender as? [PrepaidCard] {
            destinationVC.prepaidCards = prepaidCards
        }
    }

    @objc private func didPullToRefresh(_ sender: Any) {
        presenter?.pullToRefresh()
    }

    func showGetBalanceFailureToast() {
        //This Pyramid of doom is only to chain 2 view animations, and trigger the latter 1.5 seconds after the first one has finished.
        UIView.animate(withDuration: 1.5, animations: {[weak self] in
            if let unwrappedSelf = self {
                let height = unwrappedSelf.failureToastView.frame.height
                unwrappedSelf.failureToastViewBottomConstraint.constant += height
                unwrappedSelf.view.layoutIfNeeded()
            }
            }, completion: {completed in
                if completed {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.5, execute: {
                        UIView.animate(withDuration: 1.5, animations: {[weak self] in
                            if let unwrappedSelf = self {
                                unwrappedSelf.failureToastViewBottomConstraint.constant = 0.0
                                unwrappedSelf.view.layoutIfNeeded()
                            }
                        })
                    })
                }
        })
    }

    fileprivate func updateBalanceLabel(with response: HomeBalanceResponse) {
        if balanceHeaderLabel.text == "$-" {
            balanceHeaderLabel.text = response.convertedBalance
        }

        if let text = balanceHeaderLabel.text, text != "$-" {
            //swiftlint:disable:next force_unwrapping
            let currentBalanceInt = Int(String.clearTextFormat(text: text))!
            let newBalance = response.balance
            balanceHeaderLabel.countFrom(CGFloat(currentBalanceInt), to: CGFloat(newBalance), withDuration: 1.0)
        }
    }

}

// MARK: - datasource
extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            self.presenter?.userScrolledToLastGroup()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HomeTableViewCell
        let groupViewModel = self.presenter?.getGroup(at: indexPath)
        //swiftlint:disable:next force_unwrapping
        cell.setupCellWith(groupViewModel: groupViewModel!)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter?.getNumberOfGroups() ?? 0
    }
}

// MARK: - delegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: showChatDetail, sender: indexPath)
    }
}

extension HomeViewController: HomeViewProtocol {

    func setCardIconWithAlert() {
        self.creditCardButton?.setImage(#imageLiteral(resourceName: "logoVisaWhiteAlert"), for: .normal)
    }

    func setCardIconWithoutAlert() {
        self.creditCardButton?.setImage(#imageLiteral(resourceName: "logoVisaWhite"), for: .normal)
    }

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        showErrorMessage(title: "Error", message: message, completion: nil)
    }

    internal func updateBalance(response: HomeBalanceResponse) {

        updateBalanceLabel(with: response)

        if !response.convertedDate.isEmpty {

            //Delete subviews from stackview
            balanceStackView.removeSubviews()

            //Create a label with the response and add it to the stackview
            let label = createBalanceUpdatedAtLabel(with: response.convertedDate)
            balanceStackView.addArrangedSubview(label)

            //If true, we need to add the check image and then fade out the label and the check
            if response.shouldRemoveDateAfterShown {
                let checkImageView = UIImageView(image: #imageLiteral(resourceName: "checkMarkSign"))
                balanceStackView.addArrangedSubview(checkImageView)

                UIView.animate(withDuration: Constants.AnimationConstants.HomeViewController.balanceAnimationDuration, delay: Constants.AnimationConstants.HomeViewController.balanceAnimationDelay, options: .curveEaseInOut, animations: {
                    label.alpha = 0
                    checkImageView.alpha = 0
                }, completion: {[weak self] _ in
                    self?.balanceStackView.removeSubviews()
                })
            }
        }
    }

    internal func updateHistory() {
        updateTransactions()
    }

    internal func stopRefreshControl() {
        refreshControl.endRefreshing()
    }

    internal func updateTransactions() {
        setupTableViewBackground()
        homeTableView.reloadData()
    }

    internal func showSpinner() {
        spinnerLabel.presentInView(parentView: balanceHeaderLabel)
    }

    internal func hideSpinner() {
        spinnerLabel.removeFromSuperview()
    }

    internal func showSpinnerOnTable() {
        spinnerTable.presentInView(parentView: homeTableView)
    }

    internal func hideSpinnerOnTable() {
        spinnerTable.removeFromSuperview()
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    func showActivityIndicator() {
        loadingIndicator.startAnimating()
        self.homeTableView.tableFooterView?.isHidden = false
    }

    func hideActivityIndicator() {
        loadingIndicator.stopAnimating()
        setupTableViewBackground()
        self.homeTableView.tableFooterView?.isHidden = true
    }

    func showBluetoothButtonEnabled() {
        self.bluetoothButton?.setImage(#imageLiteral(resourceName: "icBluetooth-on"), for: .normal)
    }

    func showBluetoothButtonDisabled() {
        self.bluetoothButton?.setImage(#imageLiteral(resourceName: "icBluetooth-off"), for: .normal)
    }

    func hideAskForLocationView() {
        self.locationPermissionView?.hideUnscaling(from: self.view?.window)
    }

    func askForLocationServicePermission() {
        locationPermissionView?.showScaling(into: self.view?.window)
    }

    func showUpdateBalanceFailure() {
        showGetBalanceFailureToast()
    }
    
    func showCreditCardLoading() {
        self.creditCardActivityIndicator.startAnimating()
        self.creditCardButton.isHidden = true
    }
    
    func hideCreditCardLoading() {
        self.creditCardActivityIndicator.stopAnimating()
        self.creditCardButton.isHidden = false
    }
    
    func navigateToHistory() {
        performSegue(withIdentifier: historySegue, sender: nil)
    }
    
    func updateMoreBadge(with hiddenFlag: Bool) {
        profileBadge?.isHidden = hiddenFlag
    }
    
    func goToMain() {
        self.performSegue(withIdentifier: "goToMain", sender: nil)
    }

}

extension HomeViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.pushVC(viewControllerToCommit)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = homeTableView?.indexPathForRow(at: location) else { return nil }
        guard let cell = homeTableView?.cellForRow(at: indexPath) else { return nil }
        guard let chatDetailVC = storyboard?.instantiateViewController(withIdentifier: "ChatDetailViewController") as? ChatDetailViewController else { return nil }
        chatDetailVC.preferredContentSize = CGSize(width: 0.0, height: 500)
        chatDetailVC.groupViewModel = self.presenter?.getGroup(at: indexPath)
        chatDetailVC.view.layer.masksToBounds = true
        previewingContext.sourceRect = cell.frame
        return chatDetailVC
    }
}

extension HomeViewController: PermissionViewDelegate {

    func permissionAccepted(permission: Permission) {
        self.presenter?.locationPermissionAccepted()
    }

    func permissionRejected(permission: Permission) {
        self.presenter?.locationPermissionRejected()
    }
}

extension HomeViewController: EmptyTableDelegate {
    func didPressCashMach() {
        guard let selectUserVC = UIStoryboard(name: "Transaction", bundle: nil).instantiateViewController(withIdentifier: "SelectUsersViewController") as? SelectUsersViewController else { return }
        selectUserVC.transactionMode = .machRequest
        selectUserVC.viewMode = .chargeMach
        let navVC = TransactionNavigationViewController.init(rootViewController: selectUserVC)
        presentVC(navVC)
    }
}
