//
//  RecoverAccountViewController.swift
//  machApp
//
//  Created by Lukas Burns on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class RecoverAccountViewController: BaseViewController {
    
    let showAccountAlreadyExists: String = "showAccountAlreadyExists"
    let showAccountRecoveryBlocked: String = "showAccountRecoveryBlocked"
    let showRecoverAccountSuccess: String = "showRecoverAccountSuccess"
    let showRecoverAccountFailed: String = "showRecoverAccountFailed"
    
    // MARK: - Variables
    var presenter: RecoverAccountPresenterProtocol?
    var initialRut: String?

    @IBOutlet weak var rutTextField: BorderTextField!
    @IBOutlet weak var rutErrorLabel: UILabel!
    @IBOutlet weak var continueButton: LoadingButton!
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var registerStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideRutError()
        self.rutTextField.text = initialRut
        self.presenter?.rutEdited(initialRut)
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.rutTextField.setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressBar.progressToNextStep()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    @IBAction func rutTextFieldChanged(_ sender: BorderTextField) {
        self.presenter?.rutEdited(sender.text)
    }

    @IBAction func rutTextFieldEditingEnded(_ sender: Any) {
        self.presenter?.rutEndEdited()
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        self.presenter?.continueButtonPressed()
    }
    
    @IBAction func goBackTapped(_ sender: Any) {
        self.popVC()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showAccountAlreadyExists, let destinationVC = segue.destination as? RecoverAccountAlreadyExistsViewController, let authenticationResponse = sender as? AuthenticationResponse {
            destinationVC.authenticationResponse = authenticationResponse
            destinationVC.authenticationDelegate = self.presenter
        }
    }

}

extension RecoverAccountViewController: RecoverAccountViewProtocol {

    func navigateToAccountAlreadyExists(with authenticationResponse: AuthenticationResponse) {
        self.performSegue(withIdentifier: self.showAccountAlreadyExists, sender: authenticationResponse)
    }
    
    func navigateToAccountBlocked(with message: String) {
        self.performSegue(withIdentifier: showAccountRecoveryBlocked, sender: nil)
    }
    
    func navigateToAccountRecoverySuccessfull() {
        self.performSegue(withIdentifier: self.showRecoverAccountSuccess, sender: nil)
    }

    func navigateToAccountRecoveryFailed() {
        self.performSegue(withIdentifier: self.showRecoverAccountFailed, sender: nil)
    }

    func showIncorrectRutFormatError() {
        self.rutErrorLabel?.isHidden = false
        self.rutTextField?.showError()
        self.rutErrorLabel?.text = "Formato de RUT inválido. Revisa tus datos e intenta nuevamente."

    }

    func showRutDoesntExistError() {
        self.rutErrorLabel?.isHidden = false
        self.rutTextField?.showError()
        self.rutErrorLabel?.text = "No existe una cuenta MACH asociada a estos datos"
        self.registerStackView?.isHidden = false
    }
    
    func hideRutError() {
        self.rutErrorLabel?.isHidden = true
        self.registerStackView?.isHidden = true
        self.rutTextField?.hideError()
    }
    
    func enableContinueButton() {
        self.continueButton?.setAsActive()
    }
    
    func disableContinueButton() {
        self.continueButton?.setAsInactive()
    }
    
    func setContinueButtonAsLoading() {
        self.continueButton?.setAsLoading()
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }
}
