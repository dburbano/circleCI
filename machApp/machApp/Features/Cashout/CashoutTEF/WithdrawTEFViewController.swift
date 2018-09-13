//
//  WithdrawViewController.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/18/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class WithdrawTEFViewController: BaseViewController {
    
    // MARK: - Constants
    let showDisclaimer: String = "showDisclaimer"
    let showExecuteTransaction: String = "showExecuteTransaction"
    let showWithdrawMenu: String = "showWithdrawMenu"
    let maximumNumberOfDigitsForAmount: Int = 7
    let maximumNumberOfDigitsForAccount: Int = 20
    let zendeskArticleName = "filter_cashouttef"

    // MARK: - Variables
    var presenter: WithdrawTEFPresenterProtocol?
    var maxValue: Int? = 500000
    var transactionError: ExecuteTransactionError?
    
    //swiftlint:disable:next redundant_optional_initialization
    var withdrawValue: Int? = nil
    var activeField: BorderTextField?
    
    // MARK: - Outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var confirmButton: LoadingButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rutLabel: UILabel!
    @IBOutlet weak var bankField: BorderTextField!
    @IBOutlet weak var accountField: BorderTextField!
    @IBOutlet weak var amountField: BorderTextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var accountDisclaimer: UILabel!
    @IBOutlet weak var amountDisclaimer: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var numericKeyboardToolbar: UIToolbar!
    @IBOutlet weak var accountNumberErrorLabel: UILabel!
    @IBOutlet var pickerToolBar: UIToolbar!
    let picker = UIPickerView()
    
    let dimBackground = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        setupNotification()
        registerForKeyboardNotifications()
        
        self.presenter?.viewDidLoad()

        dimBackground.frame = CGRect(x: self.view.x, y: self.view.y, w: self.view.w, h: self.view.h)
        dimBackground.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        picker.delegate = self
        picker.dataSource = self
        bankField?.inputView = picker
        bankField?.inputAccessoryView = pickerToolBar
        picker.backgroundColor = UIColor.white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topView.setMachGradient()
        setupFields()
        setupView()
        createDropdownButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: true)
        self.presenter?.getBalance()
        self.presenter?.setUserInfo()
        /* This function is used to verify if the confirm button can be enabled after
         the navigation comes back from the "insert code" view, if the user hit cancel. */
        validateFields()
        
        if transactionError != nil {
            presenter?.presentAccountNumberError()
            transactionError = nil
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private
    
    private func setupFields() {
        self.bankField.setupView()
        self.accountField.setupView()
        self.amountField.setupView()
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didExecuteTransactionSuccessfully),
                                               name: .DidExecuteTransactionSuccesfully,
                                               object: nil)
    }
    
    private func setupButton() {
        confirmButton.addTinyShadow()
        self.presenter?.disable()
    }
    
    private func setupView() {
        containerView.layer.shadowColor = UIColor.black.cgColor
    }
    
    private func createDropdownButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icArrow-down"), for: .normal)
        //swiftlint:disable:next legacy_constructor
        button.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1)
        button.frame = CGRect(x: CGFloat(bankField.bounds.size.width - 22), y: CGFloat(6), width: CGFloat(18), height: CGFloat(18))
        button.imageView?.contentMode = .scaleAspectFit
        button.centerX = bankField.centerX
        button.addTarget(self, action: #selector(WithdrawTEFViewController.showBankPicker), for: .touchUpInside)
        bankField.rightViewRect(forBounds: button.frame)
        bankField.rightView = button
        bankField.rightViewMode = .always
    }

    // MARK: Notification
    //Notification: didExecuteTransactionSuccessfully
    @objc func didExecuteTransactionSuccessfully() {
        navigationController?.popToRootViewController(animated: false)
    }
    
    @objc func showBankPicker() {
        self.bankField?.becomeFirstResponder()
    }
    @IBAction func bankFieldDidBeginEditing(_ sender: Any) {
        self.view?.addSubview(dimBackground)
    }

    @IBAction func bankFieldDidEndEditing(_ sender: Any) {
        self.dimBackground.removeFromSuperview()
    }
    
    // MARK: - Actions
    @IBAction func backTapped(_ sender: Any) {
        self.presenter?.navigateBack()
    }

    @IBAction func toolBarDoneButtonTapped(_ sender: Any) {
        self.bankField?.resignFirstResponder()
    }
    
    @IBAction func didTapHiddenButton(_ sender: Any) {
        //Thib hidden button is in front of Name and RUT. It's purpose is to catch the tap event.
        presenter?.didTapHiddenButton()
    }
    
    @IBAction func helpButtonTapped(_ sender: UIButton) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().helpbox, helpTagAccessed: self.zendeskArticleName).track()
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        amountField.isWithError = false
        self.presenter?.confirmCashout()
    }
    
    // MARK: - Segue
    @IBAction func unwindToWithdraw(segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showExecuteTransaction, let cashoutViewModel = self.presenter?.getCashoutViewModel(), let destinationController = segue.destination as? ExecuteTransactionViewController {
            destinationController.cashoutViewModel = cashoutViewModel
            destinationController.transactionMode = TransactionMode.cashout
        }
    }
    
    // MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountField {
            guard let  text = textField.text else {
                return false
            }
            return string == "" ? true : text.count <= self.maximumNumberOfDigitsForAmount
        } else if textField == accountField {
            guard let  text = textField.text else {
                return false
            }
            return  string == "" ? true : text.count <= self.maximumNumberOfDigitsForAccount
        } else if textField == bankField {
            return false
        } else {
            return true
        }
    }
    
    @IBAction func didBegin(_ sender: BorderTextField) {
        if sender == amountField || sender == accountField {
            if sender == amountField {
                activeField = amountField
                amountDisclaimer.textColor = Color.warmGrey
            } else if sender == accountField {
                accountDisclaimer.isHidden = true
                activeField = accountField
            }
        }
    }
    
    @IBAction func editingChanged(_ sender: BorderTextField) {
        if sender == amountField {
            if let text = amountField.text {
                let trimmedText = String.clearTextFormat(text: text)
                presenter?.amountEdited(amount: trimmedText.toInt())
                
            }
        } else if sender == accountField {
            let cleanedAccount = accountField.text?.replacingOccurrences(of: "[^0-9 ]", with: "", options: NSString.CompareOptions.regularExpression, range: nil).trimmingCharacters(in: NSCharacterSet.whitespaces)
            
            accountField.text = cleanedAccount
            presenter?.accountEdited(cleanedAccount)
        }
    }
    
    @IBAction func editingEnded(_ sender: BorderTextField) {
        if sender == amountField || sender == accountField {
            if sender == amountField {
                if let text = sender.text {
                    presenter?.amountEndEdited(amount: String.clearTextFormat(text: text).toInt())
                }
            } else if sender == accountField {
                let cleanedAccount = accountField.text?.replacingOccurrences(of: "[^0-9 ]", with: "", options: NSString.CompareOptions.regularExpression, range: nil).trimmingCharacters(in: NSCharacterSet.whitespaces)
                
                accountField.text = cleanedAccount
                presenter?.accountEdited(cleanedAccount)
            }
            activeField = nil
        }
    }
    
    func validateFields() {
        guard let bankText = bankField.text, let accountText = accountField.text, let ammountText = amountField.text else {
            return
        }
        if !bankText.isEmpty && !accountText.isEmpty && !ammountText.isEmpty {
            /*
             Since the presenter has all fields saved(bank, account, etc)
             it is only neccessary to call one validation
             */
            presenter?.accountEdited(accountText)
        }
    }
}

// MARK: - View Protocol
extension WithdrawTEFViewController: WithdrawTEFViewProtocol {
    internal func showNameAndRutCannotBeEditedToast() {
        super.showToastWithText(text: "El Nombre y el RUT no se pueden cambiar")
    }
    
    internal func reloadBanks() {
        self.bankField?.reloadInputViews()
    }
    
    internal func setSelectedBank(at index: Int) {
        self.picker.selectRow(index, inComponent: 0, animated: true)
    }
    
    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }
    
    internal func navigateBackToMore() {
        performSegue(withIdentifier: showWithdrawMenu, sender: nil)
    }
    
    internal func enableButton() {
        if !self.confirmButton.isEnabled {
            self.confirmButton.setAsActive()
            self.confirmButton.bloatOnce()
        }
    }
    
    internal func disableButton() {
        self.confirmButton.setAsInactive()
    }
    
    internal func updateBalance(balance: Int) {
        self.balanceLabel.text = balance.toCurrency()
        self.maxValue = balance
    }
    
    internal func showAccountError() {
        self.accountField.showError()
        self.accountDisclaimer.isHidden = false
    }
    
    internal func hideAccountError() {
        self.cleanAccountLabel()
        self.accountDisclaimer.isHidden = true
    }
    
    internal func showAmountError(withMessage message: String) {
        amountDisclaimer.text = message
        amountField.showError()
        amountDisclaimer.textColor = Color.redOrange
    }
    
    internal func hideAmountError() {
        self.amountDisclaimer.text = "Monto mínimo a retirar $2.000"
        cleanAmountLabel()
        keepAmountNormalColor()
    }
    
    internal func showBalanceError() {
    }
    
    internal func hideBalanceError() {
    }
    
    internal func keepAmountNormalColor() {
        if amountField.isEditing {
            amountField.hideError()
            amountDisclaimer.textColor = Color.warmGrey
        }
    }
    
    internal func showCashoutError() {
        UIView.animate(
        withDuration: 0.5) {
            self.showAccountError()
        }
        self.bankField.showError()
        self.amountField.changeBorderLayer(color: Color.pinkishGrey)
    }
    
    internal func cleanBankLabel() {
        self.bankField.isWithError = false
    }
    
    internal func cleanAccountLabel() {
        self.accountField.isWithError = false
    }
    
    internal func cleanAmountLabel() {
        self.amountField.isWithError = false
    }
    
    internal func presentPasscode(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        guard let passcodeViewController = UIStoryboard(name: "Passcode", bundle: nil).instantiateViewController(withIdentifier: "PasscodeViewController") as? PasscodeViewController,
         let unwrappedText = amountField.text else { return }
        
        passcodeViewController.successCallback = onSuccess
        passcodeViewController.failureCallback = onFailure
        passcodeViewController.setPasscode(passcodeMode: .transactionMode, title: "Ingresa tu PIN para confirmar el retiro de " + unwrappedText + " a tu cuenta", optionText: "Cancelar")
        let navController = UINavigationController(rootViewController: passcodeViewController)
        navController.navigationBar.isHidden = true
        self.presentVC(navController)
    }
    
    internal func navigateToExecuteTransaction() {
        self.performSegue(withIdentifier: self.showExecuteTransaction, sender: self)
    }
    
    func setUserName(userName: String) {
        self.nameLabel.text = userName
    }
    
    func setRut(rut: String?) {
        self.rutLabel.text = rut?.toRutFormat()
    }
    
    func setAccountNumber(accountNumber: String) {
        self.accountField.text = accountNumber
        self.presenter?.accountEndEdited(accountNumber)
    }
    
    func setBankTexField(bankName: String) {
        self.bankField.text = bankName
    }
    
    func setAmount(with text: String) {
        amountField.text = text
    }
    
    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }
    
    func showAccountNumberError(with flag: Bool){
        accountNumberErrorLabel.isHidden = flag
    }
}

extension WithdrawTEFViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.presenter?.getNumberOfBanks() ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.presenter?.getBankName(at: row)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.presenter?.bankSelected(at: row)
    }

}

// MARK: Keyboard
extension WithdrawTEFViewController {
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let kbSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size,
            let field = activeField else { return }
        
        let contentInsets: UIEdgeInsets =  UIEdgeInsets.init(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect = view.frame
        aRect.size.height -= kbSize.height
        if !aRect.contains(field.convert(field.origin, to: view)) {
            scrollView.scrollRectToVisible(field.frame, animated: true)
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        let offset = CGPoint(x: -scrollView.contentInset.left, y: -scrollView.contentInset.top)
        scrollView.setContentOffset(offset, animated: true)
    }
}
