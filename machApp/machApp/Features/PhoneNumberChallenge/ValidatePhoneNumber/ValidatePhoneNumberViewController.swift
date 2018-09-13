//
//  ValidatePhoneNumberViewController.swift
//  machApp
//
//  Created by lukas burns on 2/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import ActiveLabel

class ValidatePhoneNumberViewController: BaseViewController {

    // MARK: - Constants
    internal let showPINNumber = "showPINNumber"
    internal let unwindToRegisterPhoneNumber = "unwindToRegisterPhoneNumber"
    internal let showAccountCreationError = "showAccountCreationError"
    internal let showCreatingAccount = "showCreatingAccount"

    let spinner: SpinnerView = SpinnerView()

    // MARK: - Variables
    var presenter: ValidatePhoneNumberPresenterProtocol?

    var verificationId: String?
    var codeExpirationTime: Int?
    var phoneNumber: String?
    var accountMode: AccountMode?

    // MARK: - Outlets

    @IBOutlet weak var verificationCodeTextField: BorderTextField!
    @IBOutlet weak var resendCodeButton: UIButton!
    @IBOutlet weak var phoneNumberLabel: ActiveLabel!
    @IBOutlet weak var errorLabel: BorderLabel!
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var continueButton: LoadingButton!

    // MARK: - Setup
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.disableContinueButton()
        setupView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.setPhoneNumber(phoneNumber: phoneNumber)
        self.presenter?.setup(verificationId: self.verificationId, codeExpirationTime: self.codeExpirationTime)
        self.presenter?.viewDidLoad(accountMode: accountMode)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.verificationCodeTextField.setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressBar.progressToNextStep()
        self.verificationCodeTextField.becomeFirstResponder()
    }

    func setupView() {
        let customType = ActiveType.custom(pattern: "\\sEditar\\b")
        phoneNumberLabel.enabledTypes = [customType]
        phoneNumberLabel.customColor[customType] = Color.greyishBrown
        phoneNumberLabel.handleCustomTap(for: customType) {[unowned self] _ in
            self.performSegue(withIdentifier: self.unwindToRegisterPhoneNumber, sender: self)
        }
        
        if let accountMode = accountMode {
            switch accountMode {
            case .recover:
                self.phoneNumberLabel?.text = "Ingresa el código que hemos enviado al teléfono +\(phoneNumber ?? "")"
            case .create:
                 self.phoneNumberLabel?.twoColorSentence(firstText: "Ingresa el código que hemos enviado al teléfono ", secondText: "+56 9 \(phoneNumber ?? "") Editar")
            }
        }
        self.resendCodeButton.isUserInteractionEnabled = false
        self.resendCodeButton.alpha = 0.3
        self.verificationCodeTextField?.delegate = self
        self.resendCodeButton?.titleLabel?.textAlignment = NSTextAlignment.center
    }

    // MARK: - Actions

    @IBAction func resendCodeButtonPressed(_ sender: Any) {
        self.presenter?.codeActionButtonPressed()
    }

    @IBAction func verificationCodeTextChanged(_ sender: Any) {
        self.presenter?.codeEdited(text: verificationCodeTextField.text)
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        self.presenter?.verifyCode()
    }

    // MARK: - Helpers

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showPINNumber, let destinationVC = segue.destination as? GeneratePINNumberViewController {
            destinationVC.accountMode = accountMode
            destinationVC.generatePinMode = GeneratePinMode.create
        }
    }

    // MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterSet = CharacterSet(charactersIn: "0123456789")
        if string.rangeOfCharacter(from: characterSet.inverted) != nil {
            return false
        }
        let maxLength = 4
        // swiftlint:disable:next force_unwrapping
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}

// MARK: - View Protocol
extension ValidatePhoneNumberViewController: ValidatePhoneNumberViewProtocol {

    func setProgressBarSteps(currentStep: Int, totalSteps: Int) {
        self.progressBar?.currentStep = currentStep
        self.progressBar?.totalSteps = totalSteps
    }

    internal func clearVerificationCode() {
        self.verificationCodeTextField.text = ""
    }

    internal func setCallButtonEnable() {
        resendCodeButton.isUserInteractionEnabled = true
        resendCodeButton.alpha = 1.0
    }

    internal func setCallButtonDisable() {
        resendCodeButton.isUserInteractionEnabled = false
        resendCodeButton.alpha = 0.3
    }

    func disableContinueButton() {
        continueButton.setAsInactive()
    }

    func enableContinueButton() {
        if !continueButton.isEnabled {
            continueButton.setAsActive()
        }
    }

    func setContinueButtonLoading() {
        continueButton.setAsLoading()
    }

    internal func showSpinner() {
        spinner.presentInView(parentView: verificationCodeTextField)
    }

    internal func hideSpinner() {
        spinner.removeFromSuperview()
        verificationCodeTextField.alpha = 1
        verificationCodeTextField.text = ""
    }

    internal func showIncorrectCodeError() {
        UIView.animate(
        withDuration: 0.7) {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "El código ingresado es incorrecto"
            self.verificationCodeTextField.showError()
        }
    }

    internal func hideIncorrectCodeError() {
        UIView.animate(
        withDuration: 0.7) {
            self.errorLabel.isHidden = true
        }
    }

    internal func disableVerificationCodeField() {
        UIView.animate(withDuration: 0.7) {
            self.verificationCodeTextField.alpha = 0.3
            self.verificationCodeTextField.isUserInteractionEnabled = false
        }
    }

    internal func enableVerificationCodeField() {
        UIView.animate(withDuration: 0.7) {
            self.verificationCodeTextField.alpha = 1
            self.verificationCodeTextField.isUserInteractionEnabled = true
        }
    }

    internal func navigateToPinNumber() {
        self.performSegue(withIdentifier: self.showPINNumber, sender: self)
    }

    internal func showCallSuccessfullMessage() {
        self.showToastWithText(text: "En unos segundos recibirás la llamada")
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {

    }
    
    func navigateToAccountCreationError() {
        self.performSegue(withIdentifier: self.showAccountCreationError, sender: nil)
    }
    
    func navigateToCreatingAccount() {
        self.performSegue(withIdentifier: self.showCreatingAccount, sender: nil)
    }
}
