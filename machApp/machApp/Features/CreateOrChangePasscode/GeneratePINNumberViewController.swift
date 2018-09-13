//
//  GeneratePINNumberViewController.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class GeneratePINNumberViewController: BaseViewController {

    // MARK: - Constants
    internal let showHome: String = "showHome"
    internal let showPinChangedSuccessfully: String = "showPinChangedSuccessfully"

    // MARK: - Variables
    var presenter: GeneratePINNUmberPresenterProtocol?
    internal var isPlaceholdersAnimationCompleted = true
    var accountMode: AccountMode?
    var generatePinMode: GeneratePinMode?

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet public var placeholders: [SignPasscodePlaceholderView] = [SignPasscodePlaceholderView]()
    @IBOutlet public var buttons: [UIButton] = [UIButton]()
    @IBOutlet public weak var placeholdersX: NSLayoutConstraint?
    @IBOutlet public weak var deleteSignButton: UIButton?
    @IBOutlet weak var disclaimerLabel: UILabel!
    @IBOutlet weak var disclaimerWidth: NSLayoutConstraint!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var dotStackView: UIStackView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var backButton: UIButton!
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        setPlaceholdersInactive()
        disclaimerLabel.isHidden = true
        checkImage.isHidden = true
        TapticEngine.selection.prepare()

        self.presenter?.setAccountMode(accountMode: accountMode)
        self.presenter?.setGeneratePinMode(pinMode: generatePinMode)

        self.setTitle()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressBar?.progressToNextStep()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let generatePinMode = self.generatePinMode else {
            return UIStatusBarStyle.lightContent
        }
        switch generatePinMode {
        case .change:
            return UIStatusBarStyle.lightContent
        case .create:
            return UIStatusBarStyle.default
        }
    }

    func setTitle() {
        guard let generatePinMode = self.generatePinMode else { return }
        switch generatePinMode {
        case .create:
            self.titleLabel?.text = "Crea tu PIN de seguridad"
            self.titleLabel?.textColor = Color.violetBlue
            self.descriptionLabel?.text = "Crea un código personal de seguridad de 4 números para ingresar a MACH"
            self.backButton?.isHidden = true
        case .change:
            self.titleLabel?.text = "Cambiar Pin de Seguridad"
            self.titleLabel?.textColor = UIColor.white
            self.descriptionLabel?.text = "Ingresa un nuevo PIN de seguridad de 4 números para ingresar a MACH"
            self.backButton?.setImage(#imageLiteral(resourceName: "icArrowBack-white"), for: .normal)
        }
    }

    func setNavigationBar() {
        if let generatePinMode = generatePinMode {
            switch generatePinMode {
            case .create:
                self.progressBar?.isHidden = false
            case .change:
                self.topView?.setMachGradient()
                self.progressBar?.isHidden = true
            }
        }
    }

    // MARK: - Actions

    @IBAction func backButtonTap(_ sender: Any) {
        self.popVC()
    }

    @IBAction func passcodeButtonTap(sender: SignPasscodeButtonView) {
        guard isPlaceholdersAnimationCompleted else { return }
        TapticEngine.selection.feedback()
        self.presenter?.addDigit(digit: sender.passcodeValue)
    }

    @IBAction func deleteButtonTap(_ sender: Any) {
        self.presenter?.removeDigit()
    }

    // MARK: - Animations
    internal func animateWrongPassword() {
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

    internal func animatePlaceholders(placeholder: [SignPasscodePlaceholderView], toState state: SignPasscodePlaceholderView.State) {
        for placeholder in placeholders {
            placeholder.animateState(state: state)
        }
    }

    internal func animatePlaceholderAtIndex(index: Int, toState state: SignPasscodePlaceholderView.State) {
        guard index < placeholders.count && index >= 0 else { return }
        placeholders[index].animateState(state: state)
    }
}

extension GeneratePINNumberViewController: GeneratePINNumberViewProtocol {

    func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }

    internal func navigateToHome() {
        self.performSegue(withIdentifier: self.showHome, sender: self)
    }

    internal func navigateToPinChangedSuccessful() {
        self.performSegue(withIdentifier: self.showPinChangedSuccessfully, sender: self)
    }

    internal func passcodeDidSucceed() {
        TapticEngine.notification.feedback(.success)
    }

    internal func passcodeDidFail() {
        TapticEngine.notification.feedback(.error)
    }

    internal func passcode(addedSignAtIndex index: Int) {
        animatePlaceholderAtIndex(index: index, toState: .active)
        deleteSignButton?.isEnabled = true
    }

    internal func passcode(removedSignAtIndex index: Int) {
        animatePlaceholderAtIndex(index: index, toState: .inactive)
        if index == 0 {
            deleteSignButton?.isEnabled = false
        }
    }

    internal func disclaimerAgain() {
        UIView.animate(withDuration: 0.7) {
            self.disclaimerWidth.constant = 180.5
            self.disclaimerLabel.isHidden = false
            self.disclaimerLabel.addBorder(width: 1.0, color: Color.aquamarine)
            self.disclaimerLabel.setCornerRadius(radius: 8.0)
            self.disclaimerLabel.text = "Vuelve a ingresar tu PIN"
            self.disclaimerLabel.textColor = UIColor.white
            self.disclaimerLabel.backgroundColor = Color.aquamarine
        }
    }

    internal func disclaimerRetry() {
        // lets disable the buttons till the message is complete.
        self.presenter?.disableButtons(pad: buttons)
        UIView.animate(withDuration: 2, delay: 0, options: .layoutSubviews, animations: {
            self.disclaimerWidth.constant = 260
            self.disclaimerLabel.addBorder(width: 1.0, color: Color.redOrange)
            self.disclaimerLabel.text = "Los códigos ingresados no coinciden"
            self.disclaimerLabel.textColor = Color.redOrange
            self.disclaimerLabel.backgroundColor = UIColor.white
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            UIView.animate(withDuration: 2, delay: 0, options: .beginFromCurrentState, animations: {
                self.disclaimerWidth.constant = 250
                self.disclaimerLabel.addBorder(width: 1.0, color: Color.aquamarine)
                self.disclaimerLabel.text = "Por favor vuelve a establecer tu PIN"
                self.disclaimerLabel.textColor = UIColor.white
                self.disclaimerLabel.backgroundColor = Color.aquamarine
                // lets enabled 'em again.
                self.presenter?.enableButtons(pad: self.buttons)
            })
        })
    }

    internal func disclaimerChecked() {
        disclaimerLabel.isHidden = true
        dotStackView.isHidden = true
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseInOut, animations: {
              self.checkImage.isHidden = false
        }, completion: { (_) in
            self.presenter?.disclaimerAnimationCompleted()
        })
    }

    internal func setPlaceholdersInactive() {
        for holder in placeholders {
            holder.animateState(state: .inactive)
        }
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }
}
