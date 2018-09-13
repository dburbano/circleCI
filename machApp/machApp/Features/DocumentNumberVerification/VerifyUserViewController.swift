//
//  RegisterUserViewController.swift
//  machApp
//
//  Created by lukas burns on 2/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class VerifyUserViewController: BaseViewController {

    // MARK: - Constants
    internal let showPhoneNumberRegistration: String = "showPhoneNumberRegistration"
    internal let showStartIdentityRecovery: String = "showStartIdentityRecovery"
    internal let showCIInformation: String = "showCIInformation"
    internal let showStartAccountRecovery: String = "showStartAccountRecovery"

    // MARK: - Variables
    var presenter: VerifyUserPresenterProtocol?
    var userInfo: UserProfile?
    var accountMode: AccountMode?

    // MARK: - Outlets
    @IBOutlet weak var registerButton: LoadingButton!
    @IBOutlet weak var rutTextField: BorderTextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var serialNumberTextField: BorderTextField!
    @IBOutlet weak var rutDisclaimer: UILabel!
    @IBOutlet weak var serialDisclaimer: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressBar: ProgressBarView!

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        self.registerButton?.setAsInactive()
        setupTexts()
        self.presenter?.viewDidLoad(accountMode)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.rutTextField.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressBar.progressToNextStep()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.rutTextField.setupView()
        self.serialNumberTextField.setupView()
    }

    @IBAction func goBackButtonPressed(_ sender: UIButton) {
        self.popVC()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func unwindToVerifyIdentity(segue: UIStoryboardSegue) {
        print("Back to Verify Identity")
    }

    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        _ = UnwindScaleSegue(identifier: unwindSegue.identifier, source: unwindSegue.source, destination: unwindSegue.destination)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    func setupTextFields() {
        self.serialNumberTextField.autocapitalizationType = UITextAutocapitalizationType.allCharacters

        self.rutTextField.delegate = self
        self.serialNumberTextField.delegate = self
        self.rutTextField.classDelegate = self
        self.serialNumberTextField.classDelegate = self

        self.serialDisclaimer.setCornerRadius(radius: 4.0)
        self.serialDisclaimer.layer.borderWidth = 1.0
        self.serialDisclaimer.layer.borderColor = Color.redOrange.cgColor

        self.rutDisclaimer.isHidden = true
        self.serialDisclaimer.isHidden = true
    }

    private func setupTexts() {
        guard let accountMode = accountMode else { return }
        switch accountMode {
        case .create:
            self.titleLabel.text = "Carnet de identidad"
        case .recover:
            self.titleLabel.text = "Recuperación de Cuenta"
        }
    }

    // MARK: - Private


    // MARK: - Actions
    @IBAction func registerUserAction(_ sender: UIButton) {
       presenter?.verifyUserIdentity()
    }

    @IBAction func rutTextFieldChanged(_ sender: BorderTextField) {
        self.presenter?.rutEdited(sender.text)
    }

    @IBAction func serialNumberTextFieldChanged(_ sender: BorderTextField) {
        self.presenter?.serialNumberEdited(sender.text)
    }

    @IBAction func helpButtonTapped(_ sender: Any) {
        self.presenter?.showMoreInformation()
    }
    
    // MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == rutTextField {
            let characterSet = CharacterSet(charactersIn: "0123456789kK-")
            if string.rangeOfCharacter(from: characterSet.inverted) != nil {
                return false
            }
            let maxLength = 12
            // swiftlint:disable:next force_unwrapping
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else {
            var characterSet = CharacterSet(charactersIn: "0123456789aA")
            if textField.text?.count == 1 {
                characterSet = CharacterSet(charactersIn: "0123456789")
            }
            if string.rangeOfCharacter(from: characterSet.inverted) != nil {
                return false
            }
            let maxLength = 10
            // swiftlint:disable:next force_unwrapping
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
    }

    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.rutTextField {
            self.serialNumberTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == showStartIdentityRecovery, let destinationVC = segue.destination as? StartIdentityRecoveryViewController,
//            let userViewModel = sender as? UserViewModel {
//            destinationVC.userViewModel = userViewModel
//            destinationVC.userIdentity = self.presenter?.getUserIdentityInformation()
//            destinationVC.accountMode = AccountMode.recover
//        } else

        if segue.identifier == showPhoneNumberRegistration, let destinationVC = segue.destination as? RegisterPhoneNumberViewController {
            destinationVC.accountMode = accountMode
        } else if segue.identifier == showStartAccountRecovery, let destinationVC = segue.destination as? RecoverAccountViewController {
            destinationVC.initialRut = sender as? String
        }
    }
}

// MARK: - View Protocol
extension VerifyUserViewController: VerifyUserViewProtocol {

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: title, message: message, completion: onAccepted)
    }

    internal func showIncorrectNumbersError() {
        self.serialDisclaimer.text = NSLocalizedString("invalid-rut-and-serial-number-message", comment: "")
        if self.serialDisclaimer.isHidden {
            self.serialNumberTextField.showError()
            UIView.animate( withDuration: 0.7) {
                self.serialDisclaimer.isHidden = false
                self.view.layoutIfNeeded()
            }
        }
    }

    func showBlockedError() {
        self.serialDisclaimer.text = "Este rut se encuentra bloqueado."
        if self.serialDisclaimer.isHidden {
            UIView.animate( withDuration: 0.7) {
                self.serialDisclaimer.isHidden = false
            }
        }
    }

    func showAccountAlreadyExistError() {
        self.serialDisclaimer.text = "Ya existe una cuenta asociada a este rut."
        if self.serialDisclaimer.isHidden {
            UIView.animate( withDuration: 0.7) {
                self.serialDisclaimer.isHidden = false
            }
        }
    }

    func showAccountDoesntExistError() {
        self.serialDisclaimer.text = "No existe una cuenta MACH asociada a estos datos. Por favor revisa los números, o crea una nueva cuenta si no tienes una."
        if self.serialDisclaimer.isHidden {
            UIView.animate( withDuration: 0.7) {
                self.serialDisclaimer.isHidden = false
            }
        }
    }

    internal func hideSerialNumberError() {
        if !self.serialDisclaimer.isHidden {
            UIView.animate( withDuration: 0.7) {
                self.serialDisclaimer.isHidden = true
            }
        }
    }
    
    func hideBackButtonIfNeeded(processGoal: String) {
        switch processGoal {
        case "recover-account":
            self.backButton?.isHidden = true
        case "get-prepaid-card", "get-account-data", "cash-out-atm":
            self.backButton?.isHidden = false
        default:
            self.backButton?.isHidden = false
        }
    }

    internal func navigateToStartIdentityRecovery(userViewModel: UserViewModel) {
        // THIS SHOULD BE DELETED IN THE FUTURE, the flow now passes through authenticationNavigationController
        self.performSegue(withIdentifier: self.showStartIdentityRecovery, sender: userViewModel)
    }

    func navigateToPhoneNumberRegistration() {
        performSegue(withIdentifier: showPhoneNumberRegistration, sender: self)
    }

    internal func showRutError() {
        self.rutDisclaimer.isHidden = false
        self.rutTextField.showError()
    }

    internal func hideRutError() {
        self.rutDisclaimer.isHidden = true
        self.rutTextField.hideError()
        self.view.layoutIfNeeded()
    }

    internal func enableContinueButton() {
        if !self.registerButton.isEnabled {
            self.registerButton.setAsActive()
        }
    }

    internal func disableContinueButton() {
        self.registerButton.setAsInactive()
    }

    internal func setContinueButtonAsLoading() {
        self.registerButton.setAsLoading()
    }

    internal func presentCIInformation() {
        performSegue(withIdentifier: "showCIInformation", sender: self)
    }

    internal func setRutTextField(with text: String) {
        self.rutTextField.text = text.toRutFormat()
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }

    func showUnderAgeError() {
        self.serialDisclaimer.text = "No es posible completar el registro. Para usar Mach debes ser mayor de 18 años."
        self.serialDisclaimer.isHidden = false
        self.serialNumberTextField.showError()
    }
    
    func showNotTrustedSourceError(with message: String) {
        self.serialDisclaimer.text = message
        self.serialDisclaimer.isHidden = false
        self.serialNumberTextField?.showError()
    }

    func disableRutTextField() {
        self.rutTextField?.isEnabled = false
    }

    func setProgressBarSteps(currentStep: Int, totalSteps: Int) {
        self.progressBar?.currentStep = currentStep
        self.progressBar?.totalSteps = totalSteps
    }

    func setSerialNumberAsFirstResponder() {
        self.serialNumberTextField?.becomeFirstResponder()
    }
    
    func navigateToStartRecoverAccount(with rut: String?) {
        self.performSegue(withIdentifier: self.showStartAccountRecovery, sender: rut)
    }

}

extension VerifyUserViewController: BorderTextFieldDelegate {

    func editingBegun(_ textField: BorderTextField) {
    }

    func editingEnded(_ textField: BorderTextField) {
        if textField == rutTextField {
            self.presenter?.rutEndEdited()
        } else if textField == serialNumberTextField {
            self.presenter?.serialNumberEndEdited()
        }
    }
}
