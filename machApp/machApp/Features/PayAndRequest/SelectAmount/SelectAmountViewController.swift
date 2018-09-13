//
//  SelectAmountViewController.swift
//  machApp
//
//  Created by lukas burns on 3/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class SelectAmountViewController: BaseViewController {
    // MARK: - Constants
    let cellIdentifier: String = "UserCell"
    let showExecuteTransaction: String = "showExecuteTransaction"
    let showExecuteRequestTransaction: String = "showExecuteRequestTransaction"
    let chargeLessTooltipText: String = "¿Nos viste cara de banco? 😳"
    let cantExceedMaxText: String = "No puedes cobrar más de $500.000"

    // MARK: - Variables
    var presenter: SelectAmountPresenterProtocol?
    var userAmountViewModels: [UserAmountViewModel]?
    var transactionMode: TransactionMode?
    var viewMode: ViewMode?
    
    var previouslySetAmount: Int?
    var previouslySetMessage: String = ""
    var shouldPresentActionBlockedBySmyteTuple: (Bool, String?) = (false, nil)

    // MARK: - Outlets
    @IBOutlet weak var balanceErrorLabel: BorderLabel!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var totalAmountTextField: UITextField!
    @IBOutlet weak var confirmationButton: UIButton!
    @IBOutlet weak var balanceTextField: UILabel!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet var numericKeyboardToolbar: UIToolbar!
    @IBOutlet weak var messageTextView: MessageTextView!
    @IBOutlet weak var chargeMoreTooltip: BaseTooltipView!
    @IBOutlet weak var divideTooltip: BaseTooltipView!
    @IBOutlet weak var chargeMoreTooltipMessageLabel: UILabel!
    @IBOutlet weak var chargeLessTooltip: BaseTooltipView!
    @IBOutlet weak var chargeLessTooltipLabel: UILabel!

    @IBOutlet weak var addMeToRequestView: UIStackView!
    @IBOutlet weak var userInRequestView: UIStackView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userAmountLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    @IBOutlet weak var inputMessageView: UIView!

    @IBOutlet weak var doneMessageButton: UIButton!

    @IBOutlet weak var inputViewBottomConstraintToMessage: NSLayoutConstraint!
    @IBOutlet weak var inputViewBottomConstraintToView: NSLayoutConstraint!

    @IBOutlet weak var inputViewLeadingConstraintToView: NSLayoutConstraint!
    @IBOutlet weak var inputViewLeadingConstraintToMessage: NSLayoutConstraint!

    @IBOutlet weak var inputViewTrailingConstraintToMessage: NSLayoutConstraint!
    @IBOutlet weak var inputViewTrailingConstraintToView: NSLayoutConstraint!

    @IBOutlet var inputViewTopConstraintToMessage: NSLayoutConstraint!

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupTextField()
        setupUserProfileImage()

        self.setUserAmountLabel(amount: (self.presenter?.getUserAmount())!)

        if let viewMode = viewMode {
            switch viewMode {
            case .normalTransaction, .chargeMach:
                self.totalAmountTextField.becomeFirstResponder()
                self.presenter?.setDefaultMessage(message: "")
            case .deeplinkTransaction:
                self.presenter?.setDefaultMessage(message: previouslySetMessage)
                self.presenter?.totalAmountChanged(totalAmount: previouslySetAmount)
                self.navBar?.isHidden = false
            }
        }

        if let transactionMode = self.transactionMode {
            switch transactionMode {
            case .request:
                break
            case .payment:
                self.hideAllUserOnRequestView()
            default:
                self.hideAllUserOnRequestView()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardWillShowNotification()
        self.addKeyboardWillHideNotification()

        setupView()
        //in case that we press cancel on the passcode-view and returns to this one
        shouldEnableButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardWillHideNotification()
        self.removeKeyboardWillShowNotification()
        self.view?.endEditing(true)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let transactionMode = self.transactionMode {
            switch transactionMode {
            case .payment:
                self.topContainerView.setMachGradient(includesStatusBar: true, navigationBar: self.navBar, withRoundedBottomCorners: true, withShadow: true)
            case .request, .machRequest:
                self.topContainerView.setMachGradient(includesStatusBar: true, navigationBar: self.navBar, withRoundedBottomCorners: true, withShadow: true, gradientStyle: .secondary)
            default:
                self.topContainerView.setMachGradient(includesStatusBar: true, navigationBar: self.navBar, withRoundedBottomCorners: true, withShadow: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldPresentActionBlockedBySmyteTuple.0 {
            let vc = SmyteBlockedActionViewController()
            vc.message = shouldPresentActionBlockedBySmyteTuple.1
            presentVC(vc)
            shouldPresentActionBlockedBySmyteTuple.0 = false
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Private
    private func setupView() {
        usersTableView.register(UINib(nibName: "UserAmountTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.setNavigationTitle()
        self.setupConfirmButton()
    }
    
    private func setupPresenter() {
        self.presenter?.setTransactionMode(transactionMode)
        self.presenter?.setUsers(userAmountViewModels)
        self.presenter?.updateBalance()
        self.presenter?.viewMode = viewMode
    }
    
    private func setupUserProfileImage() {
        self.presenter?.setProfileImage()
        self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
        self.userProfileImage.clipsToBounds = true
    }

    private func hideAllUserOnRequestView() {
        self.hideAddMeToRequestView()
        self.hideUserInRequestView()
        self.separatorView.isHidden = true
    }

    private func hideAddMeToRequestView() {
        self.addMeToRequestView.isHidden = true
    }

    private func showAddMeToRequestView() {
        self.addMeToRequestView.isHidden = false
        self.presenter?.setSplitCountingUser(splitCountingUser: false)

        self.totalAmountChange()
    }

    private func hideUserInRequestView() {
        self.userInRequestView.isHidden = true
    }

    private func showUserInRequestView() {
        self.userInRequestView.isHidden = false
        self.presenter?.setSplitCountingUser(splitCountingUser: true)

        self.totalAmountChange()
    }

    func setUserAmountLabel(amount: Int) {
        self.userAmountLabel.text = amount.toCurrency()
    }

    private func setupTextField() {
        self.numericKeyboardToolbar.isTranslucent = false
        self.numericKeyboardToolbar.barTintColor = UIColor.init(gray: 247)
        self.totalAmountTextField.inputAccessoryView = self.numericKeyboardToolbar
        self.totalAmountTextField.delegate = self
    }

    private func setNavigationTitle() {
        if let transactionMode = transactionMode {
            switch transactionMode {
            case .payment:
                self.navigationItem.title = "¿Cuánto quieres pagar?"
            case .request, .machRequest:
                self.navigationItem.title = "¿Cuánto quieres cobrar?"
            default:
                break
            }
        }
    }

    private func setupConfirmButton() {
        self.confirmationButton.setTitleColor(Color.whiteTwo, for: .disabled)
        self.confirmationButton.setBackgroundColor(UIColor.white, forState: .disabled)
        self.confirmationButton.addBorder(width: 1.0, color: Color.whiteTwo)
        guard let transactionMode = transactionMode else { return }
        switch transactionMode {
        case .payment:
            self.confirmationButton.setTitle("CONFIRMAR PAGO", for: UIControlState.normal)
            self.confirmationButton.setTitleColor(UIColor.white, for: .normal)
            self.confirmationButton.setBackgroundColor(Color.reddishPink, forState: .normal)
            self.confirmationButton.setBackgroundColor(Color.lipstick, forState: .selected)
        case .request, .machRequest:
            self.confirmationButton.setTitle("CONFIRMAR COBRO", for: UIControlState.normal)
            self.confirmationButton.setTitleColor(UIColor.white, for: .normal)
            self.confirmationButton.setBackgroundColor(Color.dodgerBlue, forState: .normal)
            self.confirmationButton.setBackgroundColor(Color.mediumBlue, forState: .selected)
        default:
            break
        }
        self.confirmationButton.addTinyShadow()
    }

    private func shouldEnableButton() {
        let text = clearAmountTextFormat(text: self.totalAmountTextField?.text)
        guard let amount = text, amount.isNumber() else { return }
        self.presenter?.totalAmountEditingEnd(totalAmount: Int(amount))
    }

    func setImage(image: UIImage?, imageURL: URL?, placeholderImage: UIImage?) {
        if let image = image {
            self.userProfileImage.image = image
        } else {
            self.userProfileImage.sd_setImage(with: imageURL, placeholderImage: placeholderImage)
        }
    }

    @objc override func keyboardWillShowWithFrame(_ frame: CGRect) {
        guard self.messageTextView.isFirstResponder else { return }
        if #available(iOS 11.0, *) {
            inputViewBottomConstraintToView.constant = UIScreen.main.bounds.height - frame.origin.y - view.safeAreaInsets.bottom
        } else {
            inputViewBottomConstraintToView.constant = UIScreen.main.bounds.height - frame.origin.y
        }
        inputViewBottomConstraintToView.priority = UILayoutPriority(rawValue: 999)
        inputViewBottomConstraintToMessage.priority = UILayoutPriority(rawValue: 998)

        inputViewLeadingConstraintToView.priority = UILayoutPriority(rawValue: 999)
        inputViewLeadingConstraintToMessage.priority = UILayoutPriority(rawValue: 998)

        inputViewTrailingConstraintToView.priority = UILayoutPriority(rawValue: 999)
        inputViewTrailingConstraintToMessage.priority = UILayoutPriority(rawValue: 998)

        inputViewTopConstraintToMessage.isActive = false

        doneMessageButton.isHidden = false

        self.inputMessageView.backgroundColor = Color.winterWhite
        self.view.layoutIfNeeded()
    }

    @objc override func keyboardWillHideWithFrame(_ frame: CGRect) {
        inputViewBottomConstraintToView.priority = UILayoutPriority(rawValue: 998)
        inputViewBottomConstraintToMessage.priority = UILayoutPriority(rawValue: 999)

        inputViewLeadingConstraintToView.priority = UILayoutPriority(rawValue: 998)
        inputViewLeadingConstraintToMessage.priority = UILayoutPriority(rawValue: 999)

        inputViewTrailingConstraintToView.priority = UILayoutPriority(rawValue: 998)
        inputViewTrailingConstraintToMessage.priority = UILayoutPriority(rawValue: 999)

        inputViewTopConstraintToMessage.isActive = true

        doneMessageButton.isHidden = true

        self.inputMessageView.backgroundColor = UIColor.clear
        self.view.layoutIfNeeded()
    }

    private func totalAmountChange() {
        let text = clearAmountTextFormat(text: self.totalAmountTextField?.text)
        guard let amount = text, amount.isNumber() else {
            self.totalAmountTextField?.text = ""
            self.presenter?.totalAmountEditingEnd(totalAmount: 0)
            return
        }
        self.presenter?.totalAmountEditingEnd(totalAmount: Int(amount))
    }

    // MARK: - Actions
    @IBAction func totalAmountEditingEnd(_ sender: UITextField) {
        self.totalAmountChange()
    }

    @IBAction func totalAmountChanged(_ sender: UITextField) {
        let text = clearAmountTextFormat(text: sender.text)
        if let amount = text, amount.isNumber() {
            self.presenter?.totalAmountChanged(totalAmount: Int(amount))
        }
    }

    func clearAmountTextFormat(text: String?) -> String? {
        return text?.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ".", with: "")
    }

    @IBAction func messageViewPressed(_ sender: Any) {
        self.messageTextView?.becomeFirstResponder()
    }

    @IBAction func doneMessageButtonPressed(_ sender: Any) {
        self.presenter?.doneMessagePressed()
    }

    @IBAction func confirmPaymentButtonTapped(_ sender: UIButton) {
        self.presenter?.transactionConfirmed()
    }

    @IBAction func doneNumericKeyboardToolbarPressed(_ sender: UIBarButtonItem) {
        self.totalAmountTextField.resignFirstResponder()
    }

    func individualAmountEdited(userCell: UserAmountTableViewCell) {
        guard let amount = userCell.amountLabel.text?.toInt(),
            let index = usersTableView.indexPath(for: userCell) else {
                return
        }
        self.presenter?.individualAmountChanged(for: index, amount: amount)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.presenter?.backButtonPressed()
    }

    @IBAction func addMeToRequestButtonTapped(_ sender: UIButton) {
        self.showUserInRequestView()
        self.hideAddMeToRequestView()
    }

    @IBAction func removeUserToRequestButtonTapped(_ sender: UIButton) {
        self.hideUserInRequestView()
        self.showAddMeToRequestView()
    }

    // MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterSet = CharacterSet(charactersIn: "0123456789")
        if string.rangeOfCharacter(from: characterSet.inverted) != nil {
            return false
        }
        return true
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showExecuteTransaction, let destinationVC = segue.destination as? ExecuteTransactionViewController, let movementViewModel = self.presenter?.getMovementViewModel() {
            destinationVC.movementViewModel = movementViewModel
            destinationVC.transactionMode = self.transactionMode
            destinationVC.delegate = self
        }
        if segue.identifier == self.showExecuteRequestTransaction,
            let destinationVC = segue.destination as? ExecuteRequestTransactionViewController,
            let movementViewModel = self.presenter?.getMovementViewModel() {
            destinationVC.movementViewModel = movementViewModel
        }
    }

    override func hideKeyboard(_ sender: UITapGestureRecognizer) {
        if let touchedView = self.view.hitTest(sender.location(in: self.view), with: nil) as? UIButton, touchedView.isEqual(doneMessageButton) {
            return
        }
        self.view.endEditing(true)
    }
}

// MARK: - View Protocol
extension SelectAmountViewController: SelectAmountViewProtocol {

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: title, message: message, completion: onAccepted)
    }

    internal func showUnsufficientBalanceError() {
        balanceErrorLabel.text = "El monto ingresado excede tu saldo"
        balanceErrorLabel.isHidden = false
    }

    internal func showExceededAmountError() {
        balanceErrorLabel.text = "El monto no debe superar los $500.000"
        balanceErrorLabel.isHidden = false
    }

    internal func hideUnsufficientBalanceError() {
        balanceErrorLabel.isHidden = true
    }

    internal func updateUsers() {
        self.usersTableView.reloadData()
    }

    internal func enableConfirmationButton() {
        if !self.confirmationButton.isEnabled {
            self.confirmationButton.isEnabled = true
            self.confirmationButton.addBorder(width: 0.0, color: UIColor.clear)
        }
    }

    internal func disableConfirmationButton() {
        self.confirmationButton.isEnabled = false
        UIView.animate(
        withDuration: 0.4) {
            self.confirmationButton.isEnabled = false
            self.confirmationButton.addBorder(width: 1.0, color: Color.pinkishGrey)
        }
    }

    internal func updateBalance(balanceResponse: BalanceResponse) {
        let balance = Int(balanceResponse.balance)
        self.balanceTextField.text = Int(balance).toCurrency()
    }

    internal func updateTotalAmount(totalAmount: Int) {
        self.totalAmountTextField?.text = totalAmount.toCurrency()
    }

    internal func clearTotalAmount() {
        self.totalAmountTextField.text = ""
    }

    internal func navigateToExecuteTransaction() {
        self.performSegue(withIdentifier: self.showExecuteTransaction, sender: self)
    }

    internal func navigateToExecuteRequestTransaction() {
        self.performSegue(withIdentifier: self.showExecuteRequestTransaction, sender: self)
    }

    internal func updateMessage(text: String) {
        self.messageTextView.text = text
    }

    internal func presentPasscode(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        guard let passcodeViewController = UIStoryboard(name: "Passcode", bundle: nil).instantiateViewController(withIdentifier: "PasscodeViewController") as? PasscodeViewController else {
            return
        }
        passcodeViewController.successCallback = onSuccess
        passcodeViewController.failureCallback = onFailure
        guard let transactionMode = self.transactionMode else { return }
        switch transactionMode {
        case .payment:
            passcodeViewController.setPasscode(passcodeMode: .transactionMode, title: "Ingresa tu PIN para confirmar el pago", optionText: "Cancelar")
            let navController = UINavigationController(rootViewController: passcodeViewController)
            navController.navigationBar.isHidden = true
            self.presentVC(navController)
        case .request, .machRequest:
            passcodeViewController.setPasscode(passcodeMode: .transactionMode, title: "Ingresa tu PIN para confirmar el cobro", optionText: "Cancelar")
            let navController = UINavigationController(rootViewController: passcodeViewController)
            navController.navigationBar.isHidden = true
            self.presentVC(navController)
        default:
            break
        }
    }

    internal func navigateBack() {
        guard let navigationController = navigationController else { return }
        if navigationController.viewControllers.count == 1 {
            navigationController.dismiss(animated: true, completion: nil)
        } else {
            navigationController.popViewController(animated: true)
        }
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    func hideInputMessageView() {
        self.messageTextView?.resignFirstResponder()
    }
    
    func showDivideTooltip(with flag: Bool) {
        divideTooltip.isHidden = flag
    }
    
    func showAddUserToCharge(with flag: Bool) {
        addMeToRequestView.isHidden = flag
        separatorView.isHidden = flag
    }

    func showTooltipCanChargeMore(with flag: Bool) {
        chargeMoreTooltip.isHidden = flag
    }

    func showTooltipCannotChargeMore(with flag: Bool) {
        chargeLessTooltip.isHidden = flag
        self.chargeLessTooltipLabel.text = self.chargeLessTooltipText
    }

    func updateTooltipCanChargeMoreLabel(with message: String) {
        chargeMoreTooltipMessageLabel.text = message
    }

    func showTooltipCantExceedMax(with flag: Bool) {
        self.chargeLessTooltip.isHidden = !flag
        self.chargeLessTooltipLabel.text = self.cantExceedMaxText
    }
}

// MARK: - Table View
extension SelectAmountViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! UserAmountTableViewCell
        if let userAmountViewModel = self.presenter?.getUser(for: indexPath) {
            cell.initializeWith(userAmountViewModel: userAmountViewModel)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter?.getAllUsers().count ?? 0
    }
}

extension SelectAmountViewController: MessageTextViewDelegate {
    // *** Call layoutIfNeeded on superview for animation when changing height ***
    func textViewDidChangeHeight(_ textView: MessageTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func textViewDidChange(_ textView: UITextView) {
        self.presenter?.messageSet(message: textView.text)
    }
}

extension SelectAmountViewController: ExecuteOperationDelegate {
    func actionWasDeniedBySmyte(with message: String) {
        shouldPresentActionBlockedBySmyteTuple = (true, message)
    }
}
