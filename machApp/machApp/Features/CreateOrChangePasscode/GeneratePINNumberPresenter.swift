//
//  GeneratePINNumberPresenter.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

enum GeneratePinMode {
    case create
    case change
}

class GeneratePINNumberPresenter: GeneratePINNUmberPresenterProtocol {

    weak var view: GeneratePINNumberViewProtocol?
    var repository: GeneratePINNumberRepositoryProtocol?

    var passcode = [String]()
    var confirmPasscode = [String]()
    let passcodeLength = 4
    var accountMode: AccountMode?
    var generatePinMode: GeneratePinMode?

    required init(repository: GeneratePINNumberRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: GeneratePINNumberViewProtocol) {
        self.view = view
    }

    func setAccountMode(accountMode: AccountMode?) {
        self.accountMode = accountMode
    }

    func setGeneratePinMode(pinMode: GeneratePinMode?) {
        self.generatePinMode = pinMode
    }

    public func addDigit(digit: String) {
        if passcode.count < passcodeLength {
            passcode.append(digit)
            self.view?.passcode(addedSignAtIndex: passcode.count - 1)
            if passcode.count == passcodeLength {
                self.view?.setPlaceholdersInactive()
                self.view?.disclaimerAgain()
            }
        } else if confirmPasscode.count < passcodeLength {
            confirmPasscode.append(digit)
            self.view?.passcode(addedSignAtIndex: confirmPasscode.count - 1)
            if confirmPasscode.count == passcodeLength {
                confirmPasscodes()
            }
        }
    }

    public func removeDigit() {
        guard !passcode.isEmpty, confirmPasscode.isEmpty else {
            guard !confirmPasscode.isEmpty else { return }
            confirmPasscode.removeLast()
            self.view?.passcode(removedSignAtIndex: confirmPasscode.count)
            return
        }
        passcode.removeLast()
        self.view?.passcode(removedSignAtIndex: passcode.count)
    }

    public func enableButtons(pad: [UIButton]) {
        for button in pad {
            button.isUserInteractionEnabled = true
        }
    }

    public func disableButtons(pad: [UIButton]) {
        for button in pad {
            button.isUserInteractionEnabled = false
        }
    }

    private func confirmPasscodes() {
        if passcode != confirmPasscode {
            self.confirmPasscode.removeAll(keepingCapacity: true)
            self.passcode.removeAll(keepingCapacity: true)
            self.view?.setPlaceholdersInactive()
            self.view?.disclaimerRetry()
            self.view?.passcodeDidFail()
            return
        } else {
            self.savePasscode()
            self.view?.passcodeDidSucceed()
            self.view?.disclaimerChecked()

            if let generatePinMode = self.generatePinMode {
                switch generatePinMode {
                case .create:
                    self.performLogin()
                default:
                    break
                }
            }
        }
    }

    func disclaimerAnimationCompleted() {
        if let generatePinMode = generatePinMode {
            switch generatePinMode {
            case .create:
                if let accountMode = self.accountMode {
                    switch accountMode {
                    case .recover:
                        PermissionManager.sharedInstance.askFor(permission: Permission.contacts) { (isGranted) in
                            DispatchQueue.main.async {
                                if isGranted {
                                    ContactManager.sharedInstance.syncContacts()
                                }
                                self.view?.navigateToHome()
                            }
                        }
                    case .create:
                        self.view?.navigateToHome()
                    }
                }
            case .change:
                self.view?.navigateToPinChangedSuccessful()
            }
        }
    }

    private func performLogin() {
        AccountManager.sharedInstance.performLogin()
        APISecurityManager.sharedInstance.createCipherKeyIfNotPresent(shouldForceCreate: true)
        self.getGetAndSaveProfile()
    }

    private func savePasscode() {
        self.repository?.setEncryptedPasscode(passcode: passcode)
    }

    private func getGetAndSaveProfile() {
        self.repository?.getOwnProfile(onSuccess: { (userProfile) in
            self.saveUser(with: userProfile)
        }, onFailure: { _ in
            //In this case we should use the data saved on UserManagerCache
           
            //self.saveUser(with: UserCacheManager.sharedInstance.userProfile!)
        })
    }

    private func saveUser(with data: UserProfileResponse) {
        let user = User(userProfileResponse: data)
        if let machId = user.machId {
            AccountManager.sharedInstance.set(machId: machId)
        }
        AccountManager.sharedInstance.saveUser(user: user)
        AccountManager.sharedInstance.setNumberOfPinAttempts(number: 0)
        self.setAnalytics(for: user)
    }

    private func setAnalytics(for user: User) {
        if let machId = AccountManager.sharedInstance.getMachId() {
            // Analytics
            BranchIOManager.sharedInstance.setIdentityWith(id: machId)   
            SegmentManager.sharedInstance.identifyUser()
            SegmentManager.sharedInstance.setAlias()
            if let accountMode = accountMode {
                switch accountMode {
                case .create:
                    BranchIOManager.sharedInstance.userCompletedActionWith(campaignEvent: .createAccount)
                    SegmentAnalytics.Event.pinCreated.track()
                case .recover:
                    BranchIOManager.sharedInstance.userCompletedActionWith(campaignEvent: .recoverAccount)
                    SegmentAnalytics.Event.pinCreated.track()
                }
            }
        }
    }

    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let generatePinNumerError):
            guard let generatePinNumerError = generatePinNumerError as? GeneratePinNumberError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch generatePinNumerError {
            case .failed:
                break
            case .getProfileFailed:
                break
            }
        case .clientError(let generatePinNumerError):
            guard let generatePinNumerError = generatePinNumerError as? GeneratePinNumberError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch generatePinNumerError {
            case .failed:
                break
            case .getProfileFailed:
                break
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
}
