//
//  RegisterUserPresenter.swift
//  machApp
//
//  Created by lukas burns on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

enum AccountMode {
    case create
    case recover
}

class VerifyUserPresenter: VerifyUserPresenterProtocol {

    var repository: VerifyUserRepositoryProtocol?
    weak var view: VerifyUserViewProtocol?

    var rut: String?
    var serialNumber: String?
    var accountMode: AccountMode?
    var process: ProcessResponse?
    
    weak var challengeDelegate: ChallengeDelegate?

    required init(repository: VerifyUserRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: VerifyUserViewProtocol) {
        self.view = view
    }
    
    func setChallenge(for process: ProcessResponse, with rut: String, challengeDelegate: ChallengeDelegate) {
        self.rut = rut
        self.process = process
        self.challengeDelegate = challengeDelegate
    }

    func viewDidLoad(_ accountMode: AccountMode?) {
        self.accountMode = accountMode
        self.initializeChallenge()
    }
    
    private func initializeChallenge() {
        guard let accountMode = self.accountMode, let process = self.process else { return }
        switch accountMode {
        case .recover:
            self.view?.hideBackButtonIfNeeded(processGoal: process.goal)
            self.rut = AccountManager.sharedInstance.getRut()
            self.view?.setRutTextField(with: self.rut ?? "")
//          self.view?.setRutTextField(with: self.rut ?? AccountManager.sharedInstance.getRut() ?? "")
            self.view?.disableRutTextField()
            self.view?.setProgressBarSteps(currentStep: process.completedSteps + 1, totalSteps: process.totalSteps + 1)
        default:
            break
        }
    }

    func verifyUserIdentity() {
        let userInformation = getUserIdentityInformation()
        guard userInformation.rut.isValidRut else {
            self.view?.showRutError()
            return
        }
        self.view?.setContinueButtonAsLoading()
        guard let accountMode = accountMode else { return }
        switch accountMode {
        case .create:
            self.callIdentityVerification(with: userInformation)
        case .recover:
            self.verifyDocumentIdChallenge(with: userInformation)
        }
    }
    
    func verifyDocumentIdChallenge(with userInformation: UserIdentityVerificationInformation) {
        guard let processId = self.process?.id else { return }
                self.repository?.verifyDocumentIdChallenge(processId: processId, userInformation: userInformation, onSuccess: { (authenticationResponse) in
            let userInfo = [ SegmentAnalytics.Trait.document_number.rawValue: userInformation.rut ]
            SegmentManager.sharedInstance.identifyAnonymousUser(traits: userInfo)
        
        SegmentAnalytics.Event.idValidated(
            location: SegmentAnalytics.EventParameter.LocationType().recovery,
            method: SegmentAnalytics.EventParameter.IDVerificationMethod().manual,
            document_number: userInformation.rut
            ).track()
            if let rut = self.rut {
                AccountManager.sharedInstance.set(rut: rut)
            }
            self.challengeDelegate?.didSucceedChallenge(authenticationResponse: authenticationResponse)
        }, onFailure: { (error) in
            SegmentAnalytics.Event.idFailed(reason: error.localizedDescription, document_number: userInformation.rut).track()
            self.view?.enableContinueButton()
            self.handle(error: error)
        })
    }
    
    private func callIdentityVerification(with userInformation: UserIdentityVerificationInformation) {
        self.repository?.verifyUserIdentity(userInformation: userInformation,
        onSuccess: { (verifyUserResponse) in
            let userInfo = [ SegmentAnalytics.Trait.document_number.rawValue: userInformation.rut ]
            SegmentManager.sharedInstance.identifyAnonymousUser(traits: userInfo)
            self.handleSuccess(verifyUserResponse, rut: userInformation.rut)
        }, onFailure: { (error) in
            self.view?.enableContinueButton()
            self.handle(error: error)
        })
    }

    func getUserIdentityInformation() -> UserIdentityVerificationInformation {
        let rut = self.rut ?? ""
        let serialNumber = self.serialNumber ?? ""
        let userInformation =  UserIdentityVerificationInformation(rut: rut, serialNumber: serialNumber)
        return userInformation
    }

    private func handleSuccess(_ verifyUserResponse: VerifyUserResponse, rut: String) {
        self.view?.enableContinueButton()
        guard let accountMode = accountMode else { return }
        guard verifyUserResponse.isAccountLocked == false || verifyUserResponse.isAccountLocked == nil else {
            self.view?.showBlockedError()
            return
        }
        switch accountMode {
        case .create:
            if !doesUserAlreadyExists(verifyUserResponse: verifyUserResponse) {
                SegmentAnalytics.Event.idValidated(
                    location: SegmentAnalytics.EventParameter.LocationType().registration,
                    method: SegmentAnalytics.EventParameter.IDVerificationMethod().manual,
                    document_number: rut
                ).track()
                self.view?.navigateToPhoneNumberRegistration()
            } else {
                self.view?.showAccountAlreadyExistError()
                if let userProfile = verifyUserResponse.userProfile {
                    let user = User(userProfileResponse: userProfile)
                    let userViewModel = UserViewModel(user: user)
                    UserCacheManager.sharedInstance.userProfile = userProfile
                    SegmentAnalytics.Event.idValidated(
                        location: SegmentAnalytics.EventParameter.LocationType().recovery,
                        method: SegmentAnalytics.EventParameter.IDVerificationMethod().manual,
                        document_number: rut
                    ).track()
                    self.view?.navigateToStartIdentityRecovery(userViewModel: userViewModel)
                }
            }
        case .recover:
            if doesUserAlreadyExists(verifyUserResponse: verifyUserResponse) {
                guard let userProfile = verifyUserResponse.userProfile else {
                    self.view?.showAccountDoesntExistError()
                    return
                }
                let user = User(userProfileResponse: userProfile)
                let userViewModel = UserViewModel(user: user)
                 UserCacheManager.sharedInstance.userProfile = userProfile
                SegmentAnalytics.Event.idValidated(
                    location: SegmentAnalytics.EventParameter.LocationType().recovery,
                    method: SegmentAnalytics.EventParameter.IDVerificationMethod().manual,
                    document_number: rut
                ).track()
                self.view?.navigateToStartIdentityRecovery(userViewModel: userViewModel)
            } else {
                self.view?.enableContinueButton()
                self.view?.showAccountDoesntExistError()
            }
        }
        guard let machId = verifyUserResponse.machId else {
            print("ERROR GRAVISIMO NO ME LLEGO UN MACH ID!!!!")
            return
        }
        print("Mi Mach ID es: \(machId)")
        AccountManager.sharedInstance.set(machId: machId)
        SiftScienceManager.sharedInstance.setUserId(userId: machId)
        if let rut = self.rut {
            AccountManager.sharedInstance.set(rut: rut)
        }
    }

    private func doesUserAlreadyExists(verifyUserResponse: VerifyUserResponse) -> Bool {
        return verifyUserResponse.userProfile != nil
    }

    func rutEdited(_ text: String?) {
        self.rut = text?.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "")
        self.validateFields()
    }

    func rutEndEdited() {
        guard var rut = rut else {
            self.view?.showRutError()
            self.view?.disableContinueButton()
            return
        }
        rut = rut.replacingOccurrences(of: ".", with: "")
        if rut.first == " " {
            self.view?.setRutTextField(with: "")
            self.view?.disableContinueButton()
        } else if rut.isEmpty || !rut.isValidRut {
            self.view?.showRutError()
            self.view?.disableContinueButton()
        } else {
            self.view?.hideRutError()
            self.view?.setRutTextField(with: rut)
        }
        self.validateFields()
    }

    private func validateFields() {
        guard let rut = rut, let serialNumber = serialNumber else {
            self.view?.disableContinueButton()
            return
        }
        if rut.isValidRut && isValidSerialNumber(serialNumber) {
            self.view?.enableContinueButton()
        } else {
            self.view?.disableContinueButton()
        }
    }

    func serialNumberEdited(_ text: String?) {
        self.serialNumber = text?.uppercased()
        validateFields()
        self.view?.hideSerialNumberError()
    }

    func serialNumberEndEdited() {
        if let serial = serialNumber, !serial.isEmpty {
            validateFields()
        }
    }

    func showMoreInformation() {

        self.view?.presentCIInformation()
    }

    private func isValidSerialNumber(_ serialNumber: String) -> Bool {
        if serialNumber.count == 9 && serialNumber.isNumber() {
            return true
        } else if serialNumber.count == 10 && serialNumber.firstLetter()?.lowercased() == "a" && serialNumber.substring(from: serialNumber.index(after: serialNumber.startIndex)).isNumber() {
            return true
        } else {
            return false
        }
    }

    private func handle(error apiError: ApiError) {
        switch apiError {
        case .connectionError():
            self.view?.showNoInternetConnectionError()
        case .serverError(let verifyUserError), .clientError(let verifyUserError):
            guard let verifyUserError = verifyUserError as? VerifyUserError else { return }
            switch verifyUserError {
            case .invalidRut:
                self.view?.showIncorrectNumbersError()
            case .rutAndSerialNumberValidationFailed:
                self.view?.showIncorrectNumbersError()
            case .underAgeError:
                self.view?.showUnderAgeError()
            case .notTrustedSource(let message):
                self.view?.showNotTrustedSourceError(with: message)
            case .userAlreadyRegistered:
                self.view?.navigateToStartRecoverAccount(with: self.rut)
            }
        case .processFailedError(let errorMessage):
            self.challengeDelegate?.didProcessFailed(errorMessage: errorMessage)
        default:
            self.view?.showServerError()
        }
    }
}
