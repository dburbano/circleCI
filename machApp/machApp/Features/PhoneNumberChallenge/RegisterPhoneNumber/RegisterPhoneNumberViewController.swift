//
//  RegisterPhoneNumberViewController.swift
//  machApp
//
//  Created by lukas burns on 2/20/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class RegisterPhoneNumberViewController: BaseViewController {

    // MARK: - Constants
    internal let showPhoneNumberValidation: String = "showPhoneNumberValidation"

    // MARK: - Variables
    internal var phoneNumberRegistrationResponse: PhoneNumberRegistrationResponse?
    var presenter: RegisterPhoneNumberPresenterProtocol?
    var accountMode: AccountMode?
    let zendeskPhoneChangeName = "filter_cambiotelefono"

    // MARK: - Outlets
    @IBOutlet weak var phoneNumberTextField: BorderTextField!
    @IBOutlet weak var sendCodeButton: LoadingButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: BorderLabel!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var backButton: UIButton!
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        sendCodeButton.setAsInactive()
        setupTextFields()

        if let accountMode = accountMode {
            switch accountMode {
            case .create:
                titleLabel.text = "Número celular"
                messageLabel.text = "Te enviaremos un código por SMS para validar tu número"
                self.contactUsButton?.isHidden = true
            case .recover:
                titleLabel.text = "Número celular de tu cuenta"
                messageLabel.text = "Ingresa el número celular asociado a tu cuenta MACH y te enviaremos un código por SMS sin costo para validar tu número"
                self.contactUsButton?.isHidden = false
            }
        }
        self.presenter?.viewDidLoad(accountMode: accountMode)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.phoneNumberTextField.becomeFirstResponder()
        self.errorMessageLabel?.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressBar.progressToNextStep()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.phoneNumberTextField.setupView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    func setupTextFields() {
        self.phoneNumberTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        self.phoneNumberTextField.delegate = self
    }

    // MARK: - Actions
    @IBAction func registerPhoneNumberAction(_ sender: UIButton) {
        presenter?.registerPhoneNumber(phoneNumberInformation: getPhoneNumberInformation())
    }

    @IBAction func unwindToRegisterPhoneNumber(segue: UIStoryboardSegue) {
        //if we back to edit tha-number
        self.enableSendButton()
    }

    @IBAction func contactUsActionPressed(_ sender: Any) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskPhoneChangeName])
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showPhoneNumberValidation {
            if let destinationController = segue.destination as? ValidatePhoneNumberViewController,
                let registrationResponse = phoneNumberRegistrationResponse {
                destinationController.verificationId = registrationResponse.verificationId
                destinationController.codeExpirationTime = registrationResponse.expiration
                destinationController.phoneNumber = phoneNumberTextField.text
                destinationController.accountMode = accountMode
            }
        }
    }

    // MARK: - Private
    @objc private func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                self.sendCodeButton.isEnabled = false
                return
            }
        }
        guard
            //swiftlint:disable:next force_unwrapping
            let number = phoneNumberTextField.text, !number.isEmpty, ((phoneNumberTextField.text?.count)! >= 8)
            else {
                sendCodeButton.setAsInactive()
                return
        }
        self.enableSendButton()
    }

    private func getPhoneNumberInformation() -> PhoneNumberRegistration {
        // swiftlint:disable:next force_unwrapping
        let phoneNumber = "569" + phoneNumberTextField.text!
        AccountManager.sharedInstance.defaults.set(phoneNumber, forKey: "phoneNumber")
        let phoneNumberRegistration = PhoneNumberRegistration(phoneNumber: phoneNumber)
        return phoneNumberRegistration
    }

    // MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterSet = CharacterSet(charactersIn: "0123456789")
        if string.rangeOfCharacter(from: characterSet.inverted) != nil {
            return false
        }
        let maxLength = 8
        // swiftlint:disable:next force_unwrapping
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}

// MARK: - View Protocol
extension RegisterPhoneNumberViewController: RegisterPhoneNumberViewProtocol {

    func setProgressBarSteps(currentStep: Int, totalSteps: Int) {
        self.progressBar?.currentStep = currentStep
        self.progressBar?.totalSteps = totalSteps
    }

    func hideIncorrectPhoneError() {
        UIView.animate(
        withDuration: 0.7) {
            self.errorMessageLabel.isHidden = true
        }
    }

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }

    internal func navigateToValidatePhoneNumber(registrationResponse: PhoneNumberRegistrationResponse) {
        self.phoneNumberRegistrationResponse = registrationResponse
        self.performSegue(withIdentifier: self.showPhoneNumberValidation, sender: self)
    }

    internal func enableSendButton() {
        if !sendCodeButton.isEnabled {
            sendCodeButton.setAsActive()
        }
    }

    internal func disableSendButton() {
        sendCodeButton.setAsInactive()
    }

    internal func selectSendButton() {
       sendCodeButton.setAsLoading()
    }

    internal func showIncorrectPhoneError(correctPhoneNumber: String) {
        self.errorMessageLabel.text = "El número no coincide con el registrado en tu cuenta. \(correctPhoneNumber)"
        UIView.animate(
        withDuration: 0.7) {
            self.errorMessageLabel.isHidden = false

        }
    }

    internal func showPhoneNumberAlreadyRegisteredError() {
        self.errorMessageLabel.text = "El número ingresado ya tiene cuenta MACH, intenta con otro."
        UIView.animate(
        withDuration: 0.7) {
            self.errorMessageLabel.isHidden = false
        }
    }
    
    internal func hideBackButton() {
        self.backButton?.isHidden = true
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }
}
