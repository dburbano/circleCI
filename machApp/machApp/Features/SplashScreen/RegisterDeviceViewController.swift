//
//  AuthorizeDeviceViewController.swift
//  machApp
//
//  Created by lukas burns on 2/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class RegisterDeviceViewController: BaseViewController {

    // MARK: - Constants
    internal let verifyUser = "verifyUser"
    internal let showTermsAndConditions = "showTermsAndConditions"
    internal let showRegisterUser = "showRegisterUser"

    // MARK: - Variables
    var presenter: RegisterDevicePresenterProtocol?
    var itc: Bool = false

    // MARK: - Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var registerButton: LoadingButton!
    @IBOutlet weak var recoverButton: UIButton!
    @IBOutlet weak var termsAndConditionsCheckBox: RoundedButton!
    @IBOutlet weak var termsAndConditionsTooltip: BaseTooltipView!

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupButtons()
        self.disableRegisterButton()
        SegmentManager.sharedInstance.clearUserInformation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if itc {
            self.performSegue(withIdentifier: "showRegisterUser", sender: nil)
        }
        AlamofireNetworkLayer.sharedInstance.deleteTokens()
        self.hideNavigationBar(animated: false)
        self.enableRecoverButton()
        if self.presenter?.hasUserAcceptedTermsAndConditions() ?? false {
            self.enableRegisterButton()
        } else {
            self.disableRegisterButton()
        }
    }

    func setupView() {
        self.setMachGradient(for: [self.view, self.registerButton])
    }

    func setupButtons() {
        self.recoverButton.setTitleColor(UIColor.white, for: .normal)
        self.recoverButton.setTitleColor(Color.lightBlueGray, for: .disabled)
        self.registerButton.setTitleColor(Color.violetBlue, for: .normal)
        self.registerButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Actions
    @IBAction func beginTapped(_ sender: Any) {
        self.presenter?.registerAccount()
    }

    @IBAction func recoverAccountTapped(_ sender: Any) {
        self.presenter?.recoverAccount()
    }

    @IBAction func termsAndConditionsCheckboxTapped(_ sender: Any) {
        self.presenter?.termsAndConditionsCheckboxPressed()
    }

    @IBAction func seeTermsAndConditionsButtonTapped(_ sender: Any) {
        self.presenter?.seeTermsAndConditions()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == verifyUser, let destinationViewController = segue.destination as? VerifyUserViewController {
            destinationViewController.accountMode = .recover
         } else if segue.identifier == self.showTermsAndConditions, let destinationVC = segue.destination as? AcceptTermsAndConditionsViewController {
            destinationVC.termsAndConditionsProcess = TermsAndConditionsProcess.register
        }
    }

    // MARK: - Actions
    @IBAction func unwindToRegisterDevice(segue: UIStoryboardSegue) {
        print("Back to Register Device")
    }
}

// MARK: - View Protocol
extension RegisterDeviceViewController: RegisterDeviceViewProtocol {

    func navigateToTermsAndConditions() {
         performSegue(withIdentifier: showTermsAndConditions, sender: self)
    }

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }

    internal func navigateToVerifyIdentity() {
        performSegue(withIdentifier: verifyUser, sender: self)
    }

    internal func navigateToRegisterUser() {
        performSegue(withIdentifier: showRegisterUser, sender: self)
    }

    internal func enableRegisterButton() {
        self.registerButton?.setAsActive()
    }

    internal func disableRegisterButton() {
       self.registerButton?.setAsInactive()
    }
    
    internal func setRegisterButtonAsLoading() {
         self.registerButton?.setAsLoading()
    }

    internal func enableRecoverButton() {
        if !self.recoverButton.isEnabled {
            self.recoverButton.isEnabled = true
        }
    }

    internal func disableRecoverButton() {
        self.recoverButton.isEnabled = false
        UIView.animate(
        withDuration: 0.4) {
            self.recoverButton.isEnabled = false
        }
    }
    
    internal func showTermsAndConditionsTooltip() {
        // Sets alpha instead of hidden to mantain its size.
        self.termsAndConditionsTooltip?.alpha = 1.0
    }
    
    internal func hideTermsAndConditionsTooltip() {
        // Sets alpha instead of hidden to mantain its size.
        self.termsAndConditionsTooltip?.alpha = 0.0
    }

    func setCheckboxAsSelected() {
        self.termsAndConditionsCheckBox.setBackgroundImage(#imageLiteral(resourceName: "checkboxChecked"), for: .normal)
    }

    func setCheckboxAsUnselected() {
        self.termsAndConditionsCheckBox.setBackgroundImage(nil, for: .normal)
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }
}
