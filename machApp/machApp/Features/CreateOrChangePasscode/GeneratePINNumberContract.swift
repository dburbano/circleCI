//
//  GeneratePINNumberContract.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

protocol GeneratePINNumberViewProtocol: BaseViewProtocol {
    func navigateToHome()
    func navigateToPinChangedSuccessful()
    func passcodeDidSucceed()
    func passcodeDidFail()
    func passcode(removedSignAtIndex: Int)
    func passcode(addedSignAtIndex: Int)
    func disclaimerAgain()
    func disclaimerRetry()
    func disclaimerChecked()
    func setPlaceholdersInactive()
}

protocol GeneratePINNUmberPresenterProtocol: BasePresenterProtocol {
    func setAccountMode(accountMode: AccountMode?)
    func setGeneratePinMode(pinMode: GeneratePinMode?)
    func addDigit(digit: String)
    func removeDigit()
    func enableButtons(pad: [UIButton])
    func disableButtons(pad: [UIButton])
    func setView(view: GeneratePINNumberViewProtocol)
    func disclaimerAnimationCompleted()
}

protocol GeneratePINNumberRepositoryProtocol {
    func setEncryptedPasscode(passcode: [String])
    func getOwnProfile(onSuccess: @escaping (UserProfileResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum GeneratePinNumberError: Error {
    case failed(message: String)
    case getProfileFailed(message: String)
}

class GeneratePinNumberErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
