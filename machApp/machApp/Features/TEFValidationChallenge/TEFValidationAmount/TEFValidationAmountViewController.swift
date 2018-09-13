//
//  TEFValidationAmountViewController.swift
//  machApp
//
//  Created by Rodrigo Russell on 16/4/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class TEFValidationAmountViewController: BaseViewController {

    var presenter: TEFValidationAmountPresenterProtocol?
    var showMaxAttempsReached: String = "showAttemptsDialogueError"

    let showToValidAccountDialogue: String = "showToValidAccountDialogue"
    let showTEFInformationDialogue: String = "showTEFInformationDialogue"

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var sendAmountButton: LoadingButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.amountTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
        self.presenter?.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(invalidDeposit),
            name: .TEFVerificationDepositError,
            object: nil
        )
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    @objc func invalidDeposit() {
        self.presenter?.tefDepositFailed()
    }

    // MARK: - Actions
    @IBAction func amountChanged(_ sender: UITextField) {
        self.presenter?.amountChanged(amount: sender.text)
    }

    @IBAction func sendAmountButtonTapped(_ sender: LoadingButton) {
        self.presenter?.sendVerificationAmount()
    }

    @IBAction func infoTEFDialogueButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: self.showTEFInformationDialogue, sender: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func unwindToTEFValidationAmount(segue: UIStoryboardSegue) {

    }
}

extension TEFValidationAmountViewController: TEFValidationAmountViewProtocol {
    func navigateToAttemptsDialogueError() {
        self.performSegue(withIdentifier: self.showMaxAttempsReached, sender: self)
    }
    
    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    func navigateToValidAccountDialogue() {
        self.performSegue(withIdentifier: self.showToValidAccountDialogue, sender: nil)
    }
    
    func showIncorrectAmountError() {
        self.instructionsLabel?.text = "No es el monto que te depositamos 😰"
        self.instructionsLabel?.textColor = Color.reddishPink
        self.amountTextField.text = ""
        self.amountTextField.becomeFirstResponder()
    }

    func showInputAmounInstruction() {
        self.instructionsLabel?.text = "Ingresa el monto que te depositamos"
        self.instructionsLabel?.textColor = Color.warmGrey
        self.sendAmountButton.text = "ENVIAR"
    }

    func showInvalidTefDepositError(for accountNumber: String) {
        self.instructionsLabel?.text = "Ocurrió un error con los datos de tu cuenta \(accountNumber)"
        self.instructionsLabel?.textColor = Color.reddishPink
        self.sendAmountButton.text = "MODIFICAR CUENTA"
    }

    func enableSendButton() {
        self.sendAmountButton.setAsActive()
    }

    func disableSendButton() {
        self.sendAmountButton.setAsInactive()
    }
    
    func setSendButtonAsLoading() {
        self.sendAmountButton.setAsLoading()
    }

    internal func updateAmountTextField(amount: String) {
        self.amountTextField?.text = amount
    }
    
    func disableAmountInput() {
        self.amountTextField?.text = ""
        self.amountTextField?.isEnabled = false
    }
    
    func changeContinueButtonTextForCreateNewVerification() {
        self.sendAmountButton?.setTitle("Cambiar Cuenta", for: .normal)
    }
    
    func goBackToTEFValidationInstruction() {
        self.performSegue(withIdentifier: "showTEFValidationInstruction", sender: nil)
    }
}
