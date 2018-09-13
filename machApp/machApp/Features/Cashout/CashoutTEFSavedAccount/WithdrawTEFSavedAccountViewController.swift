//
//  WithdrawTEFSavedAccountViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 4/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class WithdrawTEFSavedAccountViewController: BaseViewController {
    
    let showExecuteTransactionSegue: String = "showExecuteTransactionSegue"

    // MARK: - Outlets
    @IBOutlet var amountNumericKeyboardToolbar: UIToolbar!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var withdrawAmountTextField: BorderTextField!
    @IBOutlet weak var amountErrorLabel: BorderLabel!
    @IBOutlet weak var continueButton: LoadingButton!
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var bankAccountNumberLabel: UILabel!
    @IBOutlet weak var bankImage: UIImageView!
    
    // MARK: - Variables
    var presenter: WithdrawTEFSavedAccountPresenterProtocol?
    var withdrawData: WithdrawData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.setAccountInfo(with: withdrawData)
        setupViews()
        setupNotification()
        setupTextField()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topContainer.setMachGradient(includesStatusBar: true, navigationBar: nil, withRoundedBottomCorners: true, withShadow: true)
        withdrawAmountTextField.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.getBalance()
    }
    
    // MARK: - Actions
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        if let text = withdrawAmountTextField?.text {
            let trimmedText = String.clearTextFormat(text: text)
            if trimmedText.isNumber() {
                presenter?.amountEdited(amount: Int(trimmedText))
            } else {
                continueButton.setAsInactive()
            }
        }
    }
    
    @IBAction func didPressContinue(_ sender: Any) {
        presenter?.confirmCashout()
    }
    
    @IBAction func didPressDeleteAccount(_ sender: Any) {
        presenter?.deleteSavedAccount()
    }
    @IBAction func didPressDone(_ sender: Any) {
        self.withdrawAmountTextField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showExecuteTransactionSegue,
            let cashoutViewModel = self.presenter?.getCashoutViewModel(),
            let destinationController = segue.destination as? ExecuteTransactionViewController {
            destinationController.cashoutViewModel = cashoutViewModel
            destinationController.transactionMode = TransactionMode.cashout
        }
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didExecuteTransactionSuccessfully),
                                               name: .DidExecuteTransactionSuccesfully,
                                               object: nil)
    }
    
    private func setupViews() {
        withdrawAmountTextField.becomeFirstResponder()
        continueButton.setAsInactive()
        presenter?.setupBankData()
    }
    
    // MARK: Notification
    //Notification: didExecuteTransactionSuccessfully
    @objc func didExecuteTransactionSuccessfully() {
        navigationController?.popToRootViewController(animated: false)
    }

    private func setupTextField() {
        self.amountNumericKeyboardToolbar.isTranslucent = false
        self.amountNumericKeyboardToolbar.barTintColor = UIColor.init(gray: 247)
        self.withdrawAmountTextField.inputAccessoryView = self.amountNumericKeyboardToolbar
        self.withdrawAmountTextField.delegate = self
    }
}

extension WithdrawTEFSavedAccountViewController: WithdrawTEFSavedAccountViewProtocol {
    
    func navigateToWithdrawTEF() {
        if let withdrawVC = UIStoryboard(name: "WithdrawTEF", bundle: nil)
            .instantiateViewController(withIdentifier: "WithdrawTEFViewController") as? WithdrawTEFViewController {
            navigationController?.pushViewController(withdrawVC, animated: true)
        }
    }
    
    func presentBankData(with bank: Bank, accountNumber: String) {
        bankNameLabel.text = bank.name
        bankAccountNumberLabel.text = accountNumber
        var imageName = ""
        switch bank.name {
        case "BCI-TBANC-NOVA":
            imageName = "logoCuentaBci"
        case"BANCO SANTANDER-SANTIAGO-BANEFE":
            imageName = "logoCuentaSantander"
        case "BANCO DE CHILE-EDWARDS-CREDICHILE":
            imageName = "logoCuentaBancoChileV1"
        case "BANCO ESTADO":
            imageName = "logoCuentaBancoEstado"
        case "SCOTIABANK":
            imageName = "logoCuentaScotiabank"
        case "BANCO FALABELLA":
            imageName = "logoCuentaBancoFalabella"
        default:
            imageName = "logoCuentaBancoGenerico"
        }
        bankImage.image = UIImage.init(named: imageName)
        
    }
    
    func didDeleteSavedAccount() {
        let actionSheet: UIAlertController = UIAlertController(title: "Quieres eliminar esta cuenta de retiro",
                                                               message: bankAccountNumberLabel.text,
                                                               preferredStyle: .alert)

        actionSheet.addAction(UIAlertAction(title: "Sí, eliminar", style: .default, handler: { [weak self] _ in
            self?.presenter?.didConfirmAccountDeletion()
        }))
        actionSheet.addAction(UIAlertAction(title: "No por ahora", style: .default, handler: nil))
        presentAlertController(alert: actionSheet, animated: true, completion: nil)
    }
    
    func passcodeSuccesfull() {
        performSegue(withIdentifier: showExecuteTransactionSegue, sender: nil)
    }
    
    func presentPasscode(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        guard let passcodeViewController = UIStoryboard(name: "Passcode", bundle: nil)
            .instantiateViewController(withIdentifier: "PasscodeViewController") as? PasscodeViewController else {
                return
        }
        passcodeViewController.successCallback = onSuccess
        passcodeViewController.failureCallback = onFailure
        
        //swiftlint:disable:next force_unwrapping
        passcodeViewController.setPasscode(passcodeMode: .transactionMode, title: "Ingresa tu PIN para confirmar el retiro de \(withdrawAmountTextField.text!) a tu cuenta", optionText: "Cancelar")
        let navController = UINavigationController(rootViewController: passcodeViewController)
        navController.navigationBar.isHidden = true
        self.presentVC(navController)
    }
    
    func presentAmountError(with text: String, textColor: UIColor, textfieldFlag: Bool, continueButtonFlag: Bool) {
        amountErrorLabel.text = text
        amountErrorLabel.textColor = textColor
        textfieldFlag ?  withdrawAmountTextField.showError() : withdrawAmountTextField.hideError()
        continueButtonFlag ? continueButton.setAsActive() : continueButton.setAsInactive()
    }
    
    func updateAmount(with string: String) {
        withdrawAmountTextField.text = string
    }
    
    func showBalanceError() {}
    
    func hideBalanceError() {}
    
    func updateBalance(balance: Int) {
        balanceLabel.text = balance.toCurrency()
    }
    
    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }
}
