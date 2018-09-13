//
//  NameViewController.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/20/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class NameViewController: BaseViewController {
    // MARK: - Constants
    internal let showPhoto: String = "showPhoto"

    // MARK: - Variables
    var presenter: NamePresenterProtocol?

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: BorderTextField!
    @IBOutlet weak var nameTextField: BorderTextField!
    @IBOutlet weak var surnameTextField: BorderTextField!
    @IBOutlet weak var continueButton: LoadingButton!
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var exampleEmailLabel: UILabel!
    @IBOutlet weak var emailTakenLabel: BorderLabel!

    // MARK: - Setup
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nameTextField.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        self.continueButton.setAsInactive()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressBar.progressToNextStep()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.nameTextField.setupView()
        self.surnameTextField.setupView()
        self.emailTextField.setupView()
    }

    // MARK: - Private
    private func setupTextFields() {
        nameTextField.delegate = self
        surnameTextField.delegate = self
        emailTextField.delegate = self
    }

    @IBAction func firstNameChanged(_ sender: Any) {
        self.presenter?.firstNameChanged(firstName: nameTextField.text)
    }

    @IBAction func lastNameChanged(_ sender: Any) {
        self.presenter?.lastNameChanged(lastName: surnameTextField.text)
    }

    @IBAction func emailChanged(_ sender: Any) {
        let trimmedEmail = emailTextField.text?.removeLeadingAndTrailingWhitespaces()
        self.emailTextField.text = trimmedEmail
        self.presenter?.emailChanged(email: emailTextField.text)
    }

    // MARK: - Actions
    @IBAction func continueTapped(_ sender: Any) {
        self.presenter?.continueButtonTapped()
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.popVC()
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showPhoto {
            if let destinationController = segue.destination as? PhotoViewController {
                destinationController.name = presenter?.firstName
                destinationController.lastName = presenter?.lastName
            }
        }
    }

    // MARK: - Actions
    @IBAction func unwindToName(segue: UIStoryboardSegue) {
        print("Back to Name")
    }

    // MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField {
            let maxLength = 70
            // swiftlint:disable:next force_unwrapping
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else {
            let characterSet = CharacterSet(charactersIn: "abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLKMNÑOPQRSTUVWXYZ áéíóúüäëïöüçÇàèìòùâêîôûÀÈÌÒÛÂÊÎÔÛÿŸ-")
            if string.rangeOfCharacter(from: characterSet.inverted) != nil {
                return false
            }
            let maxLength = 30
            // swiftlint:disable:next force_unwrapping
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
        }
    }

    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            self.surnameTextField.becomeFirstResponder()
        } else if textField == self.surnameTextField {
            self.emailTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - View Protocol
extension NameViewController: NameViewProtocol {

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }

    internal func navigateToProfilePhoto() {
        performSegue(withIdentifier: self.showPhoto, sender: self)
    }

    internal func enableContinueButton() {
        if !self.continueButton.isEnabled {
            self.continueButton.setAsActive()
            self.continueButton.bloatOnce()
        }
    }

    internal func disableContinueButton() {
        self.continueButton.setAsInactive()
    }

    internal func selectedContinueButton() {
        self.continueButton.setAsLoading()
    }

    internal func showEmailError() {
        self.exampleEmailLabel.text = "Ingresa un correo válido"
        self.exampleEmailLabel.textColor = Color.redOrange
    }

    internal func showEmailHint() {
        self.exampleEmailLabel.text = "Ej. nombre@correo.com"
        self.exampleEmailLabel.textColor = Color.warmGrey
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    func showMessage(with text: String) {
        super.showToastWithText(text: text)
    }

    func showEmailTakenError(with flag: Bool) {
        emailTakenLabel.isHidden = flag
    }
}
