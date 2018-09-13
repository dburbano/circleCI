//
//  PasscodeContracts.swift
//  machApp
//
//  Created by lukas burns on 3/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

public enum PasscodeMode {
    case transactionMode
    case loginMode
}

public protocol PasscodeViewProtocol: class {

    func passcodeDidSucceed()

    func passcodeDidFail()

    func passcode(removedSignAtIndex: Int)

    func passcode(addedSignAtIndex: Int)

    func setTitle(text: String)

    func setOption(text: String)

    func hideOptionButton()

    func showOptionButton()

    func dismissPasscode()

    func navigateToIdentityRecovery()

    func disablePINInputButtons()

    func enablePINInputButtons()

    func showAttemptsErrorFor(attempts: Int)

    func showIncorrectPINError()

    func hideError()

    func showBlockedAccountTexts()

    func enableDeleteButton()

    func disableDeleteButton()

    func isTouchIDEnabled() -> Bool

    func askForTouchIDAuthentication(onSuccess: @escaping() -> Void, onFailure: @escaping(Error?) -> Void)
    
    func hideTouchIdBtn(isHidden: Bool)
    
    func askIfUserIsAuthenticating(wasAuthenticationSuccessful: Bool, onResult: @escaping(Bool) -> Void)
}

public protocol PasscodePresenterProtocol {

    func setPasscode(passcodeMode: PasscodeMode?, title: String?, optionText: String?)

    func addDigit(digit: String)

    func removeDigit()

    func setView(view: PasscodeViewProtocol)

    func optionButtonPressed()
    
    func verifyAttempts()

    func authenticateWithBiometrics()
}

protocol PasscodeRepositoryProcotol {

    func getPasscode() -> [String]?
    
    func getEncryptedPasscode() -> String?

    func hasPasscode() -> Bool
    
    func hasEncryptedPasscode() -> Bool

    func getNumberOfAttempts() -> Int

    func resetNumberOfAttempts()

    func incrementNumberOfAttemptsByOne()
    
    func getUseTouchId() -> Bool
    
    func setEncryptedPasscode(passcode: [String])
}

enum PasscodeError: Error {
}

class PasscodeErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
