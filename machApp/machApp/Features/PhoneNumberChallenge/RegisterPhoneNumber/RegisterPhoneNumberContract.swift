//
//  RegisterPhoneNumberContract.swift
//  machApp
//
//  Created by lukas burns on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol RegisterPhoneNumberViewProtocol: BaseViewProtocol {
    func enableSendButton()
    func disableSendButton()
    func selectSendButton()
    func navigateToValidatePhoneNumber(registrationResponse: PhoneNumberRegistrationResponse)
    func showIncorrectPhoneError(correctPhoneNumber: String)
    func showPhoneNumberAlreadyRegisteredError()
    func hideIncorrectPhoneError()
    func setProgressBarSteps(currentStep: Int, totalSteps: Int)
    func hideBackButton()
}

protocol RegisterPhoneNumberPresenterProtocol: BasePresenterProtocol {
    func registerPhoneNumber(phoneNumberInformation: PhoneNumberRegistration)
    func setView(view: RegisterPhoneNumberViewProtocol)
    func viewDidLoad(accountMode: AccountMode?)
    func setChallenge(for process: ProcessResponse,with challengeDelegate: ChallengeDelegate)
}

protocol RegisterPhoneNumberRepositoryProcotol {
    func registerPhoneNumber(phoneNumberInformation: PhoneNumberRegistration, onSuccess: @escaping (PhoneNumberRegistrationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func verifyPhoneNumber(phoneNumberRegistration: PhoneNumberRegistration, processId: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum RegisterPhoneNumberError: Error {
    case incorrectPhoneNumber(message: String)
    case phoneNumberAlreadyTaken(message: String)
    case failed(message: String)
}

class RegisterPhoneNumberErrorParser: ChallengeErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == Constants.ApiError.PhoneVerification.notMatchingPhoneError {
            return ApiError.clientError(error: RegisterPhoneNumberError.incorrectPhoneNumber(message: networkError.errorMessage ?? ""))
        } else if networkError.errorType == Constants.ApiError.PhoneVerification.phoneNumberAlreadyTakenError {
            return ApiError.clientError(error: RegisterPhoneNumberError.phoneNumberAlreadyTaken(message: ""))
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
