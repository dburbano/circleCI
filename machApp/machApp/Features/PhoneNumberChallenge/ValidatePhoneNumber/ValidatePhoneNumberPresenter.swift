//
//  ValidatePhoneNumberPresenter.swift
//  machApp
//
//  Created by lukas burns on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class ValidatePhoneNumberPresenter: ValidatePhoneNumberPresenterProtocol {
    
    
    weak var view: ValidatePhoneNumberViewProtocol?
    var repository: ValidatePhoneNumberRepositoryProtocol?
    
    var remainingCodeExpirationTime: Int = Int()
    var codeExpirationTime: Int = Int()
    var verificationId: String?
    var timer: Timer = Timer()
    var hasUserRequestedPhoneCall: Bool = false
    var phoneNumber: String?
    var accountMode: AccountMode?
    weak var challengeDelegate: ChallengeDelegate?
    var process: ProcessResponse?
    var code: String?
    
    required init(repository: ValidatePhoneNumberRepositoryProtocol?) {
        self.repository = repository
    }
    
    internal func setView(view: ValidatePhoneNumberViewProtocol) {
        self.view = view
    }
    
    public func viewDidLoad(accountMode: AccountMode?) {
        self.accountMode = accountMode
        self.initializeChallenge()
    }
    
    internal func setChallenge(with response: PhoneNumberRegistrationChallengeResponse, process: ProcessResponse, delegate: ChallengeDelegate) {
        self.process = process
        self.challengeDelegate = delegate
        self.verificationId = response.verificationId
        self.codeExpirationTime = response.expiration
    }
    
    private func initializeChallenge() {
        guard let process = self.process else { return }
        self.view?.setProgressBarSteps(currentStep: process.completedSteps + 1, totalSteps: process.totalSteps + 1)
    }
    
    func setup(verificationId: String?, codeExpirationTime: Int?) {
        self.stopTimer()
        //Do not erase this validation. The point of it is to handle the case when the navigation comes via recovery. 
        if self.verificationId == nil {
            guard let auxExpirationTime = codeExpirationTime, let verificationId = verificationId else { return }
            self.codeExpirationTime = auxExpirationTime
            self.verificationId = verificationId
        }
        self.remainingCodeExpirationTime = self.codeExpirationTime
        self.runTimer(initialValue: self.codeExpirationTime)
        self.view?.clearVerificationCode()
    }
    
    func setPhoneNumber(phoneNumber: String?) {
        self.phoneNumber = "569" + (phoneNumber ?? "")
    }
    
    func codeActionButtonPressed() {
        if isTimerExpired() {
            guard let phoneNumber = phoneNumber?.cleanPhoneNumber(), let verificationId = self.verificationId else { return }
            let phoneNumberResend = PhoneNumberResend(phoneNumber: phoneNumber, verificationID: verificationId)
            self.resendPhoneNumberWhenExpired(phoneNumberResend: phoneNumberResend)
        } else if !hasUserRequestedPhoneCall {
            self.hasUserRequestedPhoneCall = true
            guard let verificationId = verificationId else { return }
            self.callPhoneVerification(verificationID: verificationId)
        }
    }
    
    func codeEdited(text: String?) {
        code = text
        guard let codeText = code else { return }
        codeText.length == 4 ? view?.enableContinueButton() : view?.disableContinueButton()
    }
    
    func verifyCode() {
        guard let verificationId = verificationId, let verificationCode = code else { return }
        let phoneNumberValidation = PhoneNumberValidation(verificationId: verificationId, verificationCode: verificationCode)
        self.validatePhoneNumber(validationInformation: phoneNumberValidation)
    }
    
    func runTimer(initialValue: Int) {
        self.codeExpirationTime = initialValue
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        self.remainingCodeExpirationTime -= 1
        if isTimerExpired() {
            self.view?.setCallButtonEnable()
            //self.view?.changeCodeActionButtonToRequestNewCode()
            self.stopTimer()
        } else {
            //self.view?.changeCodeActionButtonToPhoneCall()
            if hasTimerRun(for: 10) && !hasUserRequestedPhoneCall {
                self.view?.setCallButtonEnable()
            } else {
                self.view?.setCallButtonDisable()
            }
        }
    }
    
    func resetTimer(seconds: Int) {
        self.timer.invalidate()
        runTimer(initialValue: seconds)
    }
    
    func stopTimer() {
        self.timer.invalidate()
    }
    
    func isTimerExpired() -> Bool {
        return remainingCodeExpirationTime == 0 ? true : false
    }
    
    func hasTimerRun(for seconds: Int) -> Bool {
        return codeExpirationTime - remainingCodeExpirationTime >= seconds ? true : false
    }
    
    func validatePhoneNumber(validationInformation: PhoneNumberValidation ) {
        self.view?.hideIncorrectCodeError()
        self.view?.setContinueButtonLoading()
        guard let mode = accountMode else { return }
        switch mode {
        case .create:
            repository?.validatePhoneNumber(phoneNumberValidation: validationInformation, onSuccess: {[weak self] in
                self?.handleSMSCheckResponse(with: mode, response: nil)
            }, onFailure: {[weak self] (error) in
                self?.handleSMSCheckErrorResponse(with: error)
            })
        case .recover:
            guard let process = process else { return }
            repository?.validatePhoneNumber(phoneNumberValidation: validationInformation, processId: process.id, onSuccess: {[weak self] networkResponse in
                self?.handleSMSCheckResponse(with: mode, response: networkResponse)
            }, onFailure: {[weak self] error in
                self?.handleSMSCheckErrorResponse(with: error)
            })
        }
    }
    
    func resendPhoneNumberWhenExpired(phoneNumberResend: PhoneNumberResend) {
        guard let account = accountMode else { return }
        switch account {
        case .create:
            requestResendPhoneNumberCaseCreate(with: phoneNumberResend)
        case .recover:
            requestResendPhoneNumberCaseRecover(with: phoneNumberResend)
        }
    }
    
    func callPhoneVerification(verificationID: String) {
        guard let mode = accountMode else { return }
        switch mode {
        case .create:
            requestPhoneCallCaseCreate(with: verificationID)
        case .recover:
            requestPhoneCallCaseRecover(with: verificationID)
        }
    }
    
    //MARK: Private funcs
    
    //MARK: Send SMS
    private func handleSMSCheckResponse(with mode: AccountMode, response: AuthenticationResponse?) {
        stopTimer()
        view?.hideSpinner()
        guard let phoneNumber = phoneNumber else { return }
        switch mode {
        case .create:
            self.view?.navigateToCreatingAccount()
            SegmentAnalytics.Event.phoneValidated(location: SegmentAnalytics.EventParameter.LocationType().registration, phone: phoneNumber).track()
            NotificationManager.sharedInstance.startListeningForMessages()
        case .recover:
            if let response = response {
                SegmentAnalytics.Event.phoneValidated(location: SegmentAnalytics.EventParameter.LocationType().recovery, phone: phoneNumber).track()
                challengeDelegate?.didSucceedChallenge(authenticationResponse: response)
            }
        }
    }
    
    private func handleSMSCheckErrorResponse(with error: ApiError) {
        view?.hideSpinner()
        handle(error: error)
        view?.enableContinueButton()
    }
    
    //MARK: Resend phone
    private func requestResendPhoneNumberCaseCreate(with phoneNumberResend: PhoneNumberResend) {
        self.repository?.resendPhoneNumber(phoneNumberResendInfo: phoneNumberResend, onSuccess: {[weak self] (phoneRegistrationResponse) in
            self?.handleRequestResendPhoneNumberResponse(with: phoneRegistrationResponse)
            }, onFailure: {[weak self] (error) in
                self?.handle(error: error)
        })
    }
    
    private func requestResendPhoneNumberCaseRecover(with phoneNumberResend: PhoneNumberResend) {
        guard let process = process else { return }
        repository?.resendPhoneNumber(with: phoneNumberResend, processId: process.id, onSuccess: {[weak self] phoneRegistrationResponse in
            self?.handleRequestResendPhoneNumberResponse(with: phoneRegistrationResponse)
            }, onFailure: {[weak self] error in
                self?.handle(error: error)
        })
    }
    
    private func handleRequestResendPhoneNumberResponse(with phoneRegistrationResponse: PhoneNumberRegistrationResponse) {
        resetTimer(seconds: phoneRegistrationResponse.expiration)
        setup(verificationId: phoneRegistrationResponse.verificationId, codeExpirationTime: phoneRegistrationResponse.expiration)
        hasUserRequestedPhoneCall = false
    }
    
    //MARK: Request phone call
    private func requestPhoneCallCaseCreate(with verificationID: String) {
        self.repository?.callPhoneVerification(verificationID: verificationID, onSuccess: {[weak self] (phoneRegistrationResponse) in
            self?.handleRequestPhoneCallResponse(with: phoneRegistrationResponse)
            }, onFailure: {[weak self] (error) in
                self?.handle(error: error)
        })
    }
    
    private func requestPhoneCallCaseRecover(with verificationID: String) {
        guard let verificationId = verificationId, let process = process else { return }
        repository?.callPhoneVerification(with: RequestPhoneCallTransferModel(verificationID: verificationId), processId: process.id, onSuccess: {[weak self] phoneRegistrationResponse in
            self?.handleRequestPhoneCallResponse(with: phoneRegistrationResponse)
            }, onFailure: {[weak self] error in
                self?.handle(error: error)
        })
    }
    
    private func handleRequestPhoneCallResponse(with phoneRegistrationResponse: PhoneNumberRegistrationResponse) {
        view?.setCallButtonDisable()
        view?.showCallSuccessfullMessage()
        setup(verificationId: phoneRegistrationResponse.verificationId, codeExpirationTime: phoneRegistrationResponse.expiration)
    }
    
    //MARK: Error
    private func handle(error apiError: ApiError) {
        switch apiError {
        case .connectionError():
            self.view?.showNoInternetConnectionError()
        case .serverError(let validatePhoneNumberError):
            guard let validatePhoneNumberError = validatePhoneNumberError as? ValidatePhoneNumberError else { return }
            switch validatePhoneNumberError {
            case .callPhoneFailed:
                break
            case .accountCreationFailed:
                self.view?.navigateToAccountCreationError()
            default:
                self.view?.showServerError()
            }
        case .clientError(let validatePhoneNumberError):
            guard let validatePhoneNumberError = validatePhoneNumberError as? ValidatePhoneNumberError else { return }
            switch validatePhoneNumberError {
            case .incorrectValidationCode:
                self.view?.showIncorrectCodeError()
            case .accountCreationFailed:
                self.view?.navigateToAccountCreationError()
            case .callPhoneFailed:
                self.view?.showServerError()
            }
        case .processFailedError(let errorMessage):
            self.challengeDelegate?.didProcessFailed(errorMessage: errorMessage)
        default:
            self.view?.showServerError()
        }
    }
}
