//
//  PasscodePresenter.swift
//  machApp
//
//  Created by lukas burns on 3/29/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class PasscodePresenter: PasscodePresenterProtocol {

    let allowedNumberOfConsecutiveAttempts: Int = 5

    var repository: PasscodeRepositoryProcotol?
    weak var view: PasscodeViewProtocol?
    var passcodeMode: PasscodeMode?

    private var passcode = [String]()
    private let passcodeLength = 4

    required public init(repository: PasscodeRepositoryProcotol?) {
        self.repository = repository
        
        // this is a function to migrate a passcode to an encrypted passcode
        guard let unwrappedRepository = repository else { return }
        if unwrappedRepository.hasPasscode() && !unwrappedRepository.hasEncryptedPasscode(), let originalPasscode = self.repository?.getPasscode() {
            // encrypt original passcode
            self.repository?.setEncryptedPasscode(passcode: originalPasscode)
        }
    }

    public func setView(view: PasscodeViewProtocol) {
        self.view = view
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.passcodeCorrectlyEnteredNotified),
            name: NSNotification.Name(rawValue: Constants.Passcode.correctPasscodeEntered),
            object: nil
        )
    }

    @objc func passcodeCorrectlyEnteredNotified() {
        self.view?.hideError()
    }

    func setPasscode(passcodeMode: PasscodeMode?, title: String?, optionText: String?) {
        self.passcodeMode = passcodeMode ?? PasscodeMode.loginMode
        self.passcode.removeAll(keepingCapacity: true)
        guard !hasPINReachedMaxAttempts() else {
            blockPIN()
            return
        }
        self.view?.setTitle(text: title ?? "Ingresa tu PIN")
        self.view?.setOption(text: optionText ?? "")
        self.view?.enablePINInputButtons()
        self.view?.disableDeleteButton()
        validateAttempts()
        if self.isTouchIDEnabled() {
            self.authenticateWithBiometrics()
            self.view?.hideTouchIdBtn(isHidden: false)
        } else {
            self.view?.hideTouchIdBtn(isHidden: true)
        }
    }

    public func addDigit(digit: String) {
        passcode.append(digit)
        self.view?.passcode(addedSignAtIndex: passcode.count - 1)
        self.view?.enableDeleteButton()
        if passcode.count >= passcodeLength {
            acceptPasscode(passcode: passcode)
            passcode.removeAll(keepingCapacity: true)
            self.view?.disableDeleteButton()
        }
    }

    public func verifyAttempts() {
        validateAttempts()
    }

    private func validateAttempts() {
        let numberOfAttempts = self.repository?.getNumberOfAttempts() ?? 0
        let leftAttempts = allowedNumberOfConsecutiveAttempts - numberOfAttempts
        if leftAttempts <= 3 {
            self.view?.showAttemptsErrorFor(attempts: leftAttempts)
        }
    }

    private func acceptPasscode(passcode: [String]) {
        if let originalEncryptedPasscode = repository?.getEncryptedPasscode() {
            if passcode.compactMap({$0}).joined().sha256() == originalEncryptedPasscode {
                self.repository?.resetNumberOfAttempts()
                self.view?.hideError()
                self.view?.passcodeDidSucceed()
            } else {
                self.repository?.incrementNumberOfAttemptsByOne()
                self.view?.passcodeDidFail()
                self.showError()
                if hasPINReachedMaxAttempts() {
                    blockPIN()
                }
            }
        }
    }

    private func showError() {
        let numberOfAttempts = self.repository?.getNumberOfAttempts() ?? 0
        let leftAttempts = allowedNumberOfConsecutiveAttempts - numberOfAttempts
        if leftAttempts <= 3 {
            self.view?.showAttemptsErrorFor(attempts: leftAttempts)
        } else {
            self.view?.showIncorrectPINError()
        }
    }

    public func removeDigit() {
        guard !passcode.isEmpty else { return }
        passcode.removeLast()
        self.view?.passcode(removedSignAtIndex: passcode.count)
        if passcode.isEmpty {
            self.view?.disableDeleteButton()
        }
    }

    func optionButtonPressed() {
        guard let passcodeMode = passcodeMode else { return }
        if hasPINReachedMaxAttempts() {
            self.view?.navigateToIdentityRecovery()
            return
        }
        switch passcodeMode {
        case .loginMode:
            self.view?.navigateToIdentityRecovery()
        case .transactionMode:
            self.view?.dismissPasscode()
        }
    }

    // MARK: Touch Id
    func authenticateWithBiometrics() {
        self.view?.askForTouchIDAuthentication(onSuccess: touchIdAuthenticationSuccessful, onFailure: touchIdAuthenticationFailed)
    }
    
    private func touchIdAuthenticationSuccessful() {
        self.repository?.resetNumberOfAttempts()
        self.view?.hideError()
        self.view?.passcodeDidSucceed()
    }
    
    private func touchIdAuthenticationFailed(error: Error?) {
        // See cases
    }

    private func isTouchIDEnabled() -> Bool {
        let canUse = self.view?.isTouchIDEnabled() ?? false
        let isEnabled = repository?.getUseTouchId() ?? false
        
        return canUse && isEnabled
    }

    private func blockPIN() {
        self.view?.disablePINInputButtons()
        self.view?.showBlockedAccountTexts()
        self.view?.hideError()
    }

    private func hasPINReachedMaxAttempts() -> Bool {
        let numberOfAttempts = self.repository?.getNumberOfAttempts() ?? 0
        return numberOfAttempts >= allowedNumberOfConsecutiveAttempts
    }
}
