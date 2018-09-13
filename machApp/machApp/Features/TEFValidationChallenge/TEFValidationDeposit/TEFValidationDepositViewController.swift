//
//  TEFValidationViewController.swift
//  machApp
//
//  Created by Lukas Burns on 4/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class TEFValidationDepositViewController: BaseViewController {

    let showTEFValidationAmountView: String = "showTEFValidationAmountView"
    let showAttemptsDialogueError:String = "showAttemptsDialogueError"
    let showTooManyConsecutiveCreateErrorDialogue:String = "showTooManyConsecutiveCreateErrorDialogue"

    // MARK: - Variables
    var presenter: TEFValidationDepositPresenterProtocol?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rutLabel: UILabel!
    @IBOutlet weak var bankTextField: BorderTextField!
    @IBOutlet weak var accountNumberTextField: BorderTextField!
    @IBOutlet weak var sendTEFButton: LoadingButton!
    @IBOutlet var numericKeyboardToolbar: UIToolbar!
    @IBOutlet var pickerToolBar: UIToolbar!
    let picker = UIPickerView()

    let dimBackground = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.disableButton()
        self.accountNumberTextField?.inputAccessoryView = numericKeyboardToolbar
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
        
        dimBackground.frame = CGRect(x: self.view.x, y: self.view.y, w: self.view.w, h: self.view.h)
        dimBackground.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        picker.delegate = self
        picker.dataSource = self
        bankTextField?.inputView = picker
        bankTextField?.inputAccessoryView = numericKeyboardToolbar
        picker.backgroundColor = UIColor.white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupView()
        createDropdownButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.bankTextField.setupView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    @IBAction func doneNumbericKeyboardToolbarPressed(_ sender: Any) {
        self.view?.endEditing(true)
    }
    
    @IBAction func goBackButtonTapped(_ sender: Any) {
        self.popVC()
    }

    private func createDropdownButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icArrow-down"), for: .normal)
        //swiftlint:disable:next legacy_constructor
        button.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1)
        button.frame = CGRect(
            x: CGFloat(self.bankTextField.bounds.size.width - 22),
            y: CGFloat(6),
            width: CGFloat(18),
            height: CGFloat(18)
        )
        button.imageView?.contentMode = .scaleAspectFit
        button.centerX = self.bankTextField.centerX
        button.addTarget(
            self,
            action: #selector(TEFValidationDepositViewController.showBankPicker),
            for: .touchUpInside
        )
        self.bankTextField.rightViewRect(forBounds: button.frame)
        self.bankTextField.rightView = button
        self.bankTextField.rightViewMode = .always
    }

    @objc private func showBankPicker() {
        self.bankTextField?.becomeFirstResponder()
    }

    private func setupView() {
        self.presenter?.viewDidLoad()
    }

    @IBAction func accountNumberChanged(_ sender: Any) {
        self.presenter?.accountNumberEdited(account: self.accountNumberTextField.text)
    }
    
    @IBAction func sendTEFButtonTapped(_ sender: Any) {
        self.sendTEFButton.setAsLoading()
        self.presenter?.sendTEF(accountNumber: self.accountNumberTextField.text!)
    }

    @IBAction func accountNumberTextFieldEditingChanged(_ sender: Any) {
        self.accountNumberTextField.text = self.presenter?.cleanAccountNumber(account: self.accountNumberTextField.text!)
    }

    @IBAction func bankFieldEditingBegin(_ sender: Any) {
        self.view.addSubview(dimBackground)
    }

    @IBAction func bankFieldEditingEnded(_ sender: Any) {
        self.dimBackground.removeFromSuperview()
    }
}

extension TEFValidationDepositViewController: TEFValidationDepositViewProtocol {
    
    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    internal func navigateToTooManyAttemptsDialogue() {
        self.performSegue(withIdentifier: self.showAttemptsDialogueError, sender: self)
    }

    func navigateToTooManyConsecutiveCreateErrorDialogue() {
        self.performSegue(withIdentifier: self.showTooManyConsecutiveCreateErrorDialogue, sender: nil)
    }

    internal func cleanBankLabel() {
        self.bankTextField.isWithError = false
    }


    internal func enableButton() {
        if !self.sendTEFButton.isEnabled {
            self.sendTEFButton.setAsActive()
            self.sendTEFButton.bloatOnce()
        }
    }

    internal func disableButton() {
        self.sendTEFButton.setAsInactive()
    }

    internal func set(accountNumber: String) {
        self.accountNumberTextField.text = accountNumber
    }

    internal func set(name: String) {
        self.nameLabel.text = name
    }

    internal func set(rut: String) {
        self.rutLabel.text = rut
    }
    
    func set(bankName: String) {
        self.bankTextField?.text = bankName
    }
    
    internal func reloadBanks() {
        self.bankTextField?.reloadInputViews()
    }
    
    internal func setSelectedBank(at index: Int) {
        self.picker.selectRow(index, inComponent: 0, animated: true)
    }
}

extension TEFValidationDepositViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
