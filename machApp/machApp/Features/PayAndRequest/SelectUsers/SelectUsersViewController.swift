//
//  SelectUsersViewController.swift
//  machApp
//
//  Created by lukas burns on 3/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import Contacts
import Lottie

// Maybe Refactor this a little. create a Custom TableView for users which will allow to reuse this table.

class SelectUsersViewController: BaseViewController {

    // MARK: - Constants
    let showSelectAmount: String = "showSelectAmount"
    let showRequestNDialogue: String = "showRequestNDialogue"
    let transactionCancelled: String = "transactionCancelled"
    let embedMachProfileSegue: String = "embedMachProfileSegue"
    let embedInviteContactsSegue: String = "inviteContactsSegue"
    let cellIdentifier: String = "UserCell"
    let selectedUsersCollectionViewHeight: CGFloat = 90.0

    // MARK: - Variables
    var presenter: SelectUsersPresenterProtocol?
    var contactsPermissionView: PermissionView?
    var locationPermissionView: PermissionView?
    var transactionMode: TransactionMode?
    var viewMode: ViewMode?
    var profileViewController: MachProfileViewController?
    var maxSelecteableUsers: Int = 15
    var shouldForceSearchBarToResign: Bool = false

    // MARK: - Outlets
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var userSearchBar: UISearchBar!
    @IBOutlet weak var selectedUsersCollectionView: UICollectionView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var numberOfSelectedUsersLabel: UILabel!
    @IBOutlet weak var topContainerView: UIStackView!
    @IBOutlet weak var bluetoothButton: UIBarButtonItem!
    @IBOutlet weak var machTeamView: UIView!
    @IBOutlet weak var continueTooltip: BaseTooltipView!
    @IBOutlet weak var inviteNonMachFriendsView: UIView!

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = ConfigurationManager.sharedInstance.getMachTeamConfiguration()
        self.maxSelecteableUsers = config?.maxContactsForGroup ?? 15
        self.presenter?.viewMode = viewMode
        self.presenter?.initializeBluetooth()
        self.showNavigationBar(animated: false)
        setupView()
        self.presenter?.loadUsers()
        self.usersTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        self.presenter?.setTransactionMode(transactionMode)
        presenter?.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
         updateTopContainerView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupView() {
        self.setupUsersTableView()
        self.setupConfirmButton()
        self.setupSearchBar()
        self.initializePermissionViews()
    }

    private func setupUsersTableView() {
        usersTableView.register(UINib(nibName: "SelectUserTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }

    private func setupConfirmButton() {
        guard let transactionMode = self.transactionMode else { return }
        switch transactionMode {
        case .payment:
             self.confirmButton.backgroundColor = Color.reddishPink
        case .request:
            self.confirmButton.backgroundColor = Color.dodgerBlue
        default:
            break
        }
        self.confirmButton.isHidden = true
        self.confirmButton.addTinyShadow()
    }

    private func setupSearchBar() {
        userSearchBar.delegate = self
        userSearchBar.enablesReturnKeyAutomatically = false
        userSearchBar.makeTransparent()
        userSearchBar.setTextFieldColor(color: UIColor.white)
        userSearchBar.setTextFieldClearButtonColor(color: UIColor.white)
        userSearchBar.setPlaceHolderTextColor(color: UIColor.white.withAlphaComponent(0.5))
        userSearchBar.setSearchImageColor(color: UIColor.white)
        userSearchBar.setTextFieldBackgroundColor(color: UIColor.clear)
        userSearchBar.setTextColor(color: UIColor.white)
        //swiftlint:disable:next force_unwrapping
        userSearchBar.setTextFieldFont(font: UIFont.defaultFontLight(size: 16.0)!)
        userSearchBar.setImage(#imageLiteral(resourceName: "icSearch"), for: .search, state: .normal)
    }

    private func initializePermissionViews() {
        contactsPermissionView = PermissionView.instanceFromNib(for: .contacts)
        contactsPermissionView?.delegate = self

        locationPermissionView = PermissionView.instanceFromNib(for: .locationServices)
        locationPermissionView?.delegate = self
        locationPermissionView?.frame = self.view.bounds
    }

    internal func updateTopContainerView() {
        if self.selectedUsersCollectionView.isHidden {
            self.topContainerView.h = self.userSearchBar.h
        } else {
            self.topContainerView.h = self.selectedUsersCollectionView.h + self.userSearchBar.h
        }
        if let transactionMode = self.transactionMode {
            switch transactionMode {
            case .payment:
                self.topContainerView.setMachGradient(includesStatusBar: true, navigationBar: self.navBar, withRoundedBottomCorners: true, withShadow: true)
            case .request:
                self.topContainerView.setMachGradient(includesStatusBar: true, navigationBar: self.navBar, withRoundedBottomCorners: true, withShadow: true, gradientStyle: .secondary)
            default:
                self.topContainerView.setMachGradient(includesStatusBar: true, navigationBar: self.navBar, withRoundedBottomCorners: true, withShadow: true)
            }
        }
    }

    // MARK: - Actions
    @IBAction func continueButtonAction(_ sender: UIButton) {
        self.presenter?.continueButtonPressed()
    }

    @IBAction func backButtonAction(_ sender: Any) {
        shouldForceSearchBarToResign = true
        userSearchBar.resignFirstResponder()
        self.presenter?.backButtonPressed()

    }

    @IBAction func bluetoothButtonActionPressed(_ sender: Any) {
    self.presenter?.bluetoothButtonPressed()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSelectAmount {
            if let destinationViewController = segue.destination as? SelectAmountViewController {
                destinationViewController.userAmountViewModels = self.presenter?.getSelectedUsersAmountViewModel()
                destinationViewController.viewMode = self.presenter?.viewMode
                destinationViewController.transactionMode = transactionMode
            }
        } else if segue.identifier == transactionCancelled {
            self.view.endEditing(true)
        } else if segue.identifier == embedMachProfileSegue {
            if let destinationVC = segue.destination as? MachProfileViewController {
                profileViewController = destinationVC
                destinationVC.delegate = self
            }
        } else if segue.identifier == embedInviteContactsSegue {
            if let destinationVC = segue.destination as? InviteContactsViewController {
                destinationVC.delegate = self
            }
        }
    }

    @IBAction func unwindToSelectUsersView(segue: UIStoryboardSegue) {

    }
}

// MARK: - View Protocol

extension SelectUsersViewController: SelectUsersViewProtocol {

    func navigateToNDialogue() {
         self.performSegue(withIdentifier: self.showRequestNDialogue, sender: self)
    }

    func shouldPresentInviteUsersView(with flag: Bool) {
        inviteNonMachFriendsView.isHidden = flag
    }

    func inviteNonMachFriends(withString string: String, url: URL, excludedTypes: [UIActivityType]) {
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [string, url],
            applicationActivities: nil)
        activityViewController.excludedActivityTypes = excludedTypes

        self.present(activityViewController, animated: true, completion: nil)
    }

    func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: title, message: message, completion: onAccepted)
    }
    
    func updateUsers(at indexPaths: [IndexPath]) {
        self.usersTableView?.reloadRows(at: indexPaths, with: .automatic)
    }

    func updateUsers() {
        self.usersTableView?.reloadData()
    }

    func updateSelectedUsers() {
        self.selectedUsersCollectionView?.reloadData()
    }

    func askForContactsPermission() {
        guard let contactsPermissionView = contactsPermissionView else {
            return
        }
        //swiftlint:disable:next force_unwrapping
        contactsPermissionView.frame = CGRect(x: 0, y: 0 - (self.navBar?.h)!, w: (self.view?.w)!, h: (self.view?.h)! + (self.navBar?.h)!)
        self.view.addSubview(contactsPermissionView)
    }

    func removeAskForPermissionView() {
        contactsPermissionView?.removeFromSuperview()
    }

    func navigateToSelectAmount() {
        self.performSegue(withIdentifier: showSelectAmount, sender: self)
    }

    func showUsersSelectedView() {
        selectedUsersCollectionView.isHidden = false
        selectedUsersCollectionView.h = selectedUsersCollectionViewHeight
        updateTopContainerView()
    }

    func hideUsersSelectedView() {
        selectedUsersCollectionView.isHidden = true
        updateTopContainerView()
        profileViewController?.isSelected = false
    }

    func showContinueButton() {
        self.confirmButton.isHidden = false
    }

    func hideContinueButton() {
        self.confirmButton.isHidden = true
    }

    func showNumberOfSelectedUsersLabel(numberOfSelectedUsers: Int) {
        self.numberOfSelectedUsersLabel.text = numberOfSelectedUsers.toString
        self.numberOfSelectedUsersLabel.isHidden = false
    }

    func hideNumberOfSelectedUsersLabel() {
        self.numberOfSelectedUsersLabel.isHidden = true
    }

    func insertPlaceholder() {
        usersTableView.tableFooterView = UIView(frame: CGRect.zero)
        usersTableView.backgroundColor = UIColor.clear

        let label = UILabel()
        label.frame.size.height = 42
        label.frame.size.width = usersTableView.frame.size.width
        label.center = usersTableView.center
        label.center.y = (usersTableView.frame.size.height/2)
        label.numberOfLines = 2
        label.textColor = Color.greyishBrown
        label.font = UIFont(name: "Nunito-Regular", size: 18)
        label.text = "No hay resultados"
        label.textAlignment = .center
        label.tag = 1

        self.usersTableView.addSubview(label)
    }

    func removePlaceholder() {
        self.usersTableView.viewWithTag(1)?.removeFromSuperview()
    }

    func goBackToHome() {
        self.performSegue(withIdentifier: transactionCancelled, sender: self)
    }

    func showConfirmationAlert(title: String, message: String, onAccepted: @escaping () -> Void, onCancelled: @escaping () -> Void) {
        self.showAlert(title: title, message: message, onAccepted: onAccepted, onCancelled: onCancelled)
    }

    func searchBarResignFirstResponder() {
        userSearchBar.resignFirstResponder()
    }

    func showIncorrectNumberOfUsersError() {
        self.showError(
            title: "",
            message: "Solo puedes seleccionar \(self.maxSelecteableUsers) contactos",
            onAccepted: nil
        )
    }

    func showIncorrectNumberOfUsersError(maxSelecteableUsers: Int) {
        let plural: Bool = maxSelecteableUsers == 1 ? false : true
        self.showError(
            title: "",
            message: "Solo puedes seleccionar \(maxSelecteableUsers) contacto\(plural ? "s" : "")",
            onAccepted: nil
        )
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    func setPaymentTitle() {
        self.navigationItem.title = "¿A quién le vas a pagar?"
    }

    func setRequestTitle() {
        self.navigationItem.title = "¿A quién le vas a cobrar?"
    }

    func showBluetoothButtonEnabled() {
        self.bluetoothButton?.tintColor = Color.aquamarine
    }

    func showBluetoothButtonDisabled() {
        self.bluetoothButton?.tintColor = Color.white
    }

    func hideAskForLocationView() {
        self.locationPermissionView?.hideUnscaling(from: self.view?.window)
    }

    func askForLocationServicePermission() {
        locationPermissionView?.showScaling(into: self.view?.window)
    }

    func reloadNearUsersSection() {
        self.usersTableView.reloadSections([0], with: .fade)
    }

    func insertUsers(at indexPaths: [IndexPath]) {
        self.usersTableView.beginUpdates()
        self.usersTableView.insertRows(at: indexPaths, with: .automatic)
        self.usersTableView.endUpdates()
    }

    func insertUser(at position: Int) {
        let indexPath = IndexPath(item: position, section: 0)
        self.usersTableView.insertRows(at: [indexPath], with: .automatic)
    }

    func removeUser(at position: Int) {
        let indexPath = IndexPath(item: position, section: 0)
        self.usersTableView.deleteRows(at: [indexPath], with: .automatic)
    }

    func showNonMachUserError() {
        self.showToastWithText(text: "Este usuario todavía no tiene MACH ;).")
    }

    func inviteANonMachUser(with url: URL, text: String) {
        showAlert(with: "Este usuario no tiene MACH", message: text, okText: "Invitar a MACH", cancelText: "No por ahora", onAccepted: {
            UIApplication.shared.openURL(url)}, onCancelled: {})
    }

    func updateChargeMachTeamView() {
        machTeamView.isHidden = false
        bluetoothButton.isEnabled = false
    }

    func showContinueTooltip(with flag: Bool) {
        continueTooltip.isHidden = flag
    }
}

// MARK: - UITable Data Source

extension SelectUsersViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SelectUserTableViewCell
        let user = self.presenter?.getUser(for: indexPath)
        if let user = user {
            cell.initializeWith(user: user, sortOrder: CNContactsUserDefaults.shared().sortOrder, viewMode: presenter?.viewMode)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter?.getNumberOfUsersForSection(section) ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.presenter?.getNumberOfSections() ?? 0
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.presenter?.getUserIndexTitles()
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.presenter?.getSectionForIndexTitle(title) ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && !(self.presenter?.isNearContactsEnabled())! && !(self.presenter?.isFilterEnabled())! {
            return nil
        }
        if self.presenter?.getNumberOfUsersForSection(section) == 0 {
            return nil
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, w: tableView.frame.size.width, h: 25))
        headerView.backgroundColor = .white
        let label = UILabel(frame: CGRect(x: 10, y: 7, w: tableView.frame.size.width, h: 25))
        label.text = self.presenter?.getTitleForUserSection(section)
        label.font = UIFont.defaultFontBold(size: 18.0)
        label.tintColor = Color.greyishBrown
        headerView.addSubview(label)
        return headerView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 && (self.presenter?.isNearContactsEnabled())! && self.presenter?.getNumberOfUsersForSection(0) == 0 && !(self.presenter?.isFilterEnabled())! {

            let animationView = LOTAnimationView(name: "search_animation")
            animationView.contentMode = .scaleAspectFit
            animationView.loopAnimation = true
            let label = UILabel(x: 0, y: 150 - 20, w: tableView.w, h: 20)
            label.text = "Buscando"
            label.textColor = Color.aquamarine
            label.font = UIFont.defaultFontLight(size: 17.0)
            animationView.addSubview(label)
            label.textAlignment = .center
            animationView.play()

            return animationView
        } else { return nil}
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && (self.presenter?.isNearContactsEnabled())! && self.presenter?.getNumberOfUsersForSection(0) == 0 && !(self.presenter?.isFilterEnabled())! {
            return 150
        } else { return 0 }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 && !(self.presenter?.isNearContactsEnabled())! && !(self.presenter?.isFilterEnabled())!) || self.presenter?.getNumberOfUsersForSection(section) == 0 {
            return 0
        } else { return 25 }
    }
}

// MARK: - UITableViewDelegate

extension SelectUsersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if userSearchBar.isFirstResponder {
            userSearchBar.becomeFirstResponder()
        }
        self.presenter?.userSelected(at: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let text = userSearchBar.text else { return }
        /*
         We have 2 cases:
         If the search bar has no text, we should resign the keyboard IF the search bar is focused. Otherwise we shouldnt.
         If the search bar has text, then we should not resign the keyboard
         */
        shouldForceSearchBarToResign = text.isEmpty ? userSearchBar.isFirstResponder : false

    }
}

// MARK: - UISearchBarDellegate

extension SelectUsersViewController: UISearchBarDelegate {

    func clearSearchBar() {
        userSearchBar.text = ""
        searchBar(userSearchBar, textDidChange: "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.presenter?.inputSearchText(searchText)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        userSearchBar.becomeFirstResponder()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return shouldForceSearchBarToResign
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.presenter?.searchButtonClicked()
        shouldForceSearchBarToResign = true
        searchBar.resignFirstResponder()
    }
}

// MARK: UICollectionViewDataSource
extension SelectUsersViewController: UICollectionViewDataSource, RemovableCollectionViewCellDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.getSelectedUsersCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let selectedUserCellIdentifier = "SelectedUserCell"

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: selectedUserCellIdentifier, for: indexPath) as? SelectedUserCollectionViewCell else { return SelectedUserCollectionViewCell() }
        let user = self.presenter?.getSelectedUser(for: indexPath)
        cell.initializeWith(user: user)
        cell.delegate = self
        return cell
    }

    func removeViewCell(cell: UICollectionViewCell) {
        if let indexPath = selectedUsersCollectionView.indexPath(for: cell) {
            presenter?.selectedUserRemoved(at: indexPath)
        }
    }
}

extension SelectUsersViewController: PermissionViewDelegate {

    func permissionAccepted(permission: Permission) {
        switch permission {
        case .contacts:
            self.presenter?.contactsPermissionAccepted()
        case .locationServices:
            self.presenter?.locationPermissionAccepted()
        default:
            break
        }
    }

    func permissionRejected(permission: Permission) {
        switch permission {
        case .contacts:
            self.presenter?.contactsPermissionRejected()
        case .locationServices:
            self.presenter?.locationPermissionRejected()
        default:
            break
        }
    }
}

// MARK: MachProfileCellDelegate
extension SelectUsersViewController: MachProfileCellDelegate {
    func didPress(cell: MachProfileViewController, with data: MachTeamConfiguration) {
        // Only allow the user to tap on mach profile, if such profile has not been selected
        if var presenter = presenter, !presenter.isMachProfileSelected {
            presenter.isMachProfileSelected = true
            cell.isSelected = true
        }
    }
}

// MARK: InviteContactsDelegate
extension SelectUsersViewController: InviteContactsDelegate {
    func didPressInviteContacts() {
        presenter?.sendInvitationToNonMachUser()
    }
}
