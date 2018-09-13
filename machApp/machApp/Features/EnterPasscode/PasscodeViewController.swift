//
//  PinViewController.swift
//  machApp
//
//  Created by lukas burns on 3/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import LocalAuthentication

class PasscodeViewController: BaseViewController {

    // MARK: - Constants
    let gradient: CAGradientLayer = CAGradientLayer()

    // MARK: - Variables
    var presenter: PasscodePresenterProtocol?
    public var successCallback: (() -> Void)?
    public var failureCallback: (() -> Void)?
    public var dismissCompletionCallback: (() -> Void)?
    internal var isPlaceholdersAnimationCompleted = true
    internal var passcodeMode: PasscodeMode?
    internal var titleMessage: String?
    internal var optionText: String?
    var backgroundTimerTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var hasTimerExpired: Bool?
    var updateTimer: Timer?
    var context: LAContext?

    // MARK: - Outlets
    @IBOutlet public var placeholders: [PasscodePlaceholderView] = [PasscodePlaceholderView]()
    @IBOutlet public var passcodeButtons: [PasscodeButtonView] = [PasscodeButtonView]()
    @IBOutlet public weak var optionButton: UIButton?
    @IBOutlet public weak var deleteSignButton: UIButton?
    @IBOutlet public weak var touchIDButton: UIButton?
    @IBOutlet public weak var placeholdersX: NSLayoutConstraint?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorLabel: BorderLabel!
    @IBOutlet weak var touchIdBtn: UIButton!
    
    // MARK: - Setup

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setMachGradient(includesStatusBar: true, navigationBar: nil, withRoundedBottomCorners: false, withShadow: false)
        TapticEngine.selection.prepare()
        self.view.frame = UIScreen.main.bounds
        self.tabBarController?.isNavBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleDidEnterBackgroundwith), name: .ApplicationDidEnterBackground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: false)
        self.presenter?.setPasscode(passcodeMode: passcodeMode, title: titleMessage, optionText: optionText)
        self.animatePlaceholders(placeholder: self.placeholders, toState: .inactive)
        self.presenter?.verifyAttempts()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    func setPasscode(passcodeMode: PasscodeMode, title: String, optionText: String) {
        self.passcodeMode = passcodeMode
        self.titleMessage = title
        self.optionText = optionText
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //Handle ApplicationDidEnterBackground notification
    @objc func handleDidEnterBackgroundwith(notification: Notification) {
        context?.invalidate()
    }

    // MARK: - Actions
    @IBAction func passcodeButtonTap(sender: PasscodeButtonView) {
        TapticEngine.selection.feedback()
        guard isPlaceholdersAnimationCompleted else { return }
        self.presenter?.addDigit(digit: sender.passcodeValue)
    }

    @IBAction func deleteButtonTap(_ sender: Any) {
        self.presenter?.removeDigit()
    }

    @IBAction func optionButtonTapped(_ sender: Any) {
        self.presenter?.optionButtonPressed()
    }

    @IBAction func touchIDButtonTap(sender: UIButton) {
        self.presenter?.authenticateWithBiometrics()
    }

    internal func closePasscode(completionHandler: (() -> Void)? = nil) {
        dismiss(animated: true, completion: { [weak self] in
            self?.dismissCompletionCallback?()
        })
        dismissCompletionCallback?()
        completionHandler?()
    }

    // MARK: - Animations
    internal func animateWrongPassword() {
        deleteSignButton?.isEnabled = false
        isPlaceholdersAnimationCompleted = false
        animatePlaceholders(placeholder: placeholders, toState: .error)
        placeholdersX?.constant = -40
        view.layoutIfNeeded()

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.placeholdersX?.constant = 0
                self.view.layoutIfNeeded()
        },
            completion: { _ in
                self.isPlaceholdersAnimationCompleted = true
                self.animatePlaceholders(placeholder: self.placeholders, toState: .inactive)
        })
    }

    internal func animatePlaceholders(placeholder: [PasscodePlaceholderView], toState state: PasscodePlaceholderView.State) {
        for placeholder in placeholders {
            placeholder.animateState(state: state)
        }
    }

    internal func animatePlaceholderAtIndex(index: Int, toState state: PasscodePlaceholderView.State) {
        guard index < placeholders.count && index >= 0 else { return }
        placeholders[index].animateState(state: state)
    }
}

// MARK: - View Protocol
extension PasscodeViewController: PasscodeViewProtocol {

    public func passcodeDidSucceed() {
        deleteSignButton?.isEnabled = true
        TapticEngine.notification.feedback(.success)
        Thread.runOnMainQueue(0.5, completion: {
            self.closePasscode(completionHandler: { [weak self] in
                self?.successCallback?()
                self?.animatePlaceholders(placeholder: (self?.placeholders)!, toState: .inactive)
            })
        })
    }

    public func passcodeDidFail() {
        animateWrongPassword()
        self.failureCallback?()
        TapticEngine.notification.feedback(.error)
    }

    public func passcode(addedSignAtIndex index: Int) {
        animatePlaceholderAtIndex(index: index, toState: .active)
    }

    public func passcode(removedSignAtIndex index: Int) {
        animatePlaceholderAtIndex(index: index, toState: .inactive)
    }

    public func setTitle(text: String) {
        self.titleLabel?.text = text
    }

    func setOption(text: String) {
        self.optionButton?.setTitle(text, for: .normal)
    }

    public func hideOptionButton() {
        self.optionButton?.isHidden = true
    }

    public func showOptionButton() {
        self.optionButton?.isHidden = false
    }

    public func dismissPasscode() {
        self.closePasscode()
    }

    public func showAttemptsErrorFor(attempts: Int) {
        self.errorLabel.isHidden = false
        self.errorLabel.text = "Has ingresado un PIN incorrecto\nTe quedan \(attempts) intentos."
    }

    public func hideError() {
        self.errorLabel?.isHidden = true
    }

    func showIncorrectPINError() {
        self.errorLabel.isHidden = false
        self.errorLabel.text = "El PIN ingresado es incorrecto."
    }

    func disablePINInputButtons() {
        for passcodeButton in passcodeButtons {
            passcodeButton.isEnabled = false
        }
    }

    func enablePINInputButtons() {
        for passcodeButton in passcodeButtons {
            passcodeButton.isEnabled = true
        }
    }

    func showBlockedAccountTexts() {
        self.titleLabel.text = "Tu cuenta se encuentra bloqueada"
        self.optionButton?.setTitle("Recuperar Cuenta", for: .normal)
        view.layoutIfNeeded()
    }

    func navigateToIdentityRecovery() {
        let storyboard = UIStoryboard(name: "RecoverAccount", bundle: nil)
        if let recoverAccountVC = storyboard.instantiateViewController(withIdentifier: "RecoverAccountViewController") as? RecoverAccountViewController {
            self.pushVC(recoverAccountVC)
        }
    }

    func enableDeleteButton() {
        self.deleteSignButton?.isEnabled = true
    }

    func disableDeleteButton() {
        self.deleteSignButton?.isEnabled = false
    }

    func isTouchIDEnabled() -> Bool {
        let context = LAContext()
        var error: NSError?
        let canUseTouchId = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        return canUseTouchId
    }

    func askForTouchIDAuthentication(onSuccess: @escaping() -> Void, onFailure: @escaping(Error?) -> Void) {
        context = LAContext()
        context?.localizedFallbackTitle = "" // hide Enter Password option
        context?.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Ingresa con tu huella") { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.animatePlaceholders(placeholder: self.placeholders, toState: .active)
                    onSuccess()
                } else {
                    switch error!._code {
                    case LAError.Code.systemCancel.rawValue:
                        super.showErrorMessage(title: "Cancelado", message: error!.localizedDescription, completion: nil)
                    case LAError.Code.userCancel.rawValue: // Cancel option
                        break
                    case LAError.Code.userFallback.rawValue: // Enter Password option (hidden)
                        break
                    case LAError.Code.touchIDLockout.rawValue: // Wrong fingerprint 5 times
                        let msg = "Tu huella no fue reconocida 5 veces. Ahora podrás usar sólo tu PIN. Bloquea y desbloquea tu iPhone para que puedas usar nuevamente Touch ID."
                        super.showErrorMessage(title: "Falló Autenticación", message: msg, completion: nil)
                        self.hideTouchIdBtn(isHidden: true)
                    case LAError.Code.authenticationFailed.rawValue: // Wrong fingerprint 3 times
                        let msg = "Tu huella no fue reconocida 3 veces. Ahora tienes que usar tu PIN."
                        super.showErrorMessage(title: "Falló Autenticación", message: msg, completion: nil)
                        self.hideTouchIdBtn(isHidden: true)
                    default:
                        break
                    }
                    onFailure(error)
                }
            }
        }
    }
    
    func hideTouchIdBtn(isHidden: Bool) {
        touchIdBtn.isHidden = isHidden
    }

    func askIfUserIsAuthenticating(wasAuthenticationSuccessful: Bool,onResult: @escaping(Bool) -> Void) {
        self.showAlert(with: wasAuthenticationSuccessful ? "Autenticación Exitosa" : "Autenticación Fallida", message: "Dinos si eras tu autenticandote", okText: "Si", cancelText: "No", onAccepted: {
            onResult(true)
        }) {
            onResult(false)
        }
    }
}

