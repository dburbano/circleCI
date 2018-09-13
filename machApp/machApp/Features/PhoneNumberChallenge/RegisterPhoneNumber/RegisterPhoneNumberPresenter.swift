//
//  RegisterPhoneNumberPresenter.swift
//  machApp
//
//  Created by lukas burns on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class RegisterPhoneNumberPresenter: RegisterPhoneNumberPresenterProtocol {

    weak var view: RegisterPhoneNumberViewProtocol?
    var repository: RegisterPhoneNumberRepositoryProcotol?

    var accountMode: AccountMode?
    var process: ProcessResponse?
    weak var challengeDelegate: ChallengeDelegate?

    required init(repository: RegisterPhoneNumberRepositoryProcotol?) {
        self.repository = repository
    }

    internal func setView(view: RegisterPhoneNumberViewProtocol) {
        self.view = view
    }
    
    internal func setChallenge(for process: ProcessResponse,with challengeDelegate: ChallengeDelegate) {
        self.process = process
        self.challengeDelegate = challengeDelegate
    }

    func viewDidLoad(accountMode: AccountMode?) {
        self.accountMode = accountMode
        self.initializeChallenge()
    }
    
    private func initializeChallenge() {
        guard let process = self.process else { return }
        self.view?.setProgressBarSteps(currentStep: process.completedSteps + 1, totalSteps: process.totalSteps + 1)
        if let accountMode = accountMode {
            switch accountMode {
            case .recover:
                self.view?.hideBackButton()
            case .create:
                break
            }
        }
    }

    func registerPhoneNumber(phoneNumberInformation: PhoneNumberRegistration ) {

        guard let account = accountMode,
            phoneNumberInformation.phoneNumber.isValidPhoneNumber else { return }
        self.view?.selectSendButton()
        self.view?.hideIncorrectPhoneError()
        let userInfo = [ SegmentAnalytics.Trait.phone.rawValue: "+\(phoneNumberInformation.phoneNumber)" ]
        SegmentManager.sharedInstance.identifyAnonymousUser(traits: userInfo)
        switch account {
        case .create:
            handleCreateCase(with: phoneNumberInformation)
        case .recover:
            handleRecoverCase(with: phoneNumberInformation)
        }
    }
    
    private func handleCreateCase(with phoneNumberInformation: PhoneNumberRegistration) {
        repository?.registerPhoneNumber(phoneNumberInformation: phoneNumberInformation,
                                        onSuccess: {[weak self] (phoneRegistrationResponse) in
                                            UserCacheManager.sharedInstance.userProfile?.phone = phoneNumberInformation.phoneNumber
                                            self?.view?.navigateToValidatePhoneNumber(registrationResponse: phoneRegistrationResponse)},
                                        onFailure: {[weak self] (error) in
                                            self?.view?.enableSendButton()
                                            self?.handle(error: error)})
    }
    
    private func handleRecoverCase(with phoneNumberInformation: PhoneNumberRegistration) {
        guard let processID = process?.id else { return }
        repository?.verifyPhoneNumber(phoneNumberRegistration: PhoneNumberRegistration(phoneNumber: phoneNumberInformation.phoneNumber),processId: processID,
                                      onSuccess: {[weak self] response in
                                        self?.challengeDelegate?.didSucceedChallenge(authenticationResponse: response) },
                                      onFailure: {[weak self] error in
                                        self?.view?.enableSendButton()
                                        self?.handle(error: error)})
    }

    private func handle(error apiError: ApiError) {
        switch apiError {
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let registerPhoneNumberError):
            handleServerError(with: registerPhoneNumberError)
        case .clientError(let registerPhoneNumberError):
            handleClientError(with: registerPhoneNumberError)
        case .processFailedError(let errorMessage):
            self.challengeDelegate?.didProcessFailed(errorMessage: errorMessage)
        default:
            self.view?.showServerError()
        }
    }

    private func handleServerError(with registerPhoneNumberError: Error) {
        guard let registerPhoneNumberError = registerPhoneNumberError as? RegisterPhoneNumberError else { return }

        switch registerPhoneNumberError {
        case .failed, .incorrectPhoneNumber, .phoneNumberAlreadyTaken:
            self.view?.showServerError()
        }
    }

    private func handleClientError(with registerPhoneNumberError: Error) {
            guard let registerPhoneNumberError = registerPhoneNumberError as? RegisterPhoneNumberError else { return }
            switch registerPhoneNumberError {
            case .failed( _):
                break
            case .incorrectPhoneNumber(let message):
                self.view?.showIncorrectPhoneError(correctPhoneNumber: message)
            case .phoneNumberAlreadyTaken( _):
                self.view?.showPhoneNumberAlreadyRegisteredError()
            }
    }
}
