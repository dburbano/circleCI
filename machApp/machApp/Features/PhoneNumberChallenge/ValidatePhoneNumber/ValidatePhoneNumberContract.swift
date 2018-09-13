//
//  ValidatePhoneNumberContract.swift
//  machApp
//
//  Created by lukas burns on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol ValidatePhoneNumberViewProtocol: BaseViewProtocol {

//    func changeCodeActionButtonToPhoneCall()
//
//    func changeCodeActionButtonToRequestNewCode()

    func setCallButtonEnable()

    func setCallButtonDisable()

    func showSpinner()

    func hideSpinner()

    func showIncorrectCodeError()

    func hideIncorrectCodeError()

    func disableVerificationCodeField()

    func enableVerificationCodeField()

    func navigateToPinNumber()

    func showCallSuccessfullMessage()

    func clearVerificationCode()

    func disableContinueButton()

    func enableContinueButton()
    
    func setContinueButtonLoading()

    func navigateToAccountCreationError()

    func setProgressBarSteps(currentStep: Int, totalSteps: Int)

    func navigateToCreatingAccount()
}

protocol ValidatePhoneNumberPresenterProtocol: BasePresenterProtocol {

    func setView(view: ValidatePhoneNumberViewProtocol)

    func setup(verificationId: String?, codeExpirationTime: Int?)

    func viewDidLoad(accountMode: AccountMode?)

    func setPhoneNumber(phoneNumber: String?)

    func codeActionButtonPressed()

    func codeEdited(text: String?)
    
    func verifyCode()
    
    func setChallenge(with response: PhoneNumberRegistrationChallengeResponse, process: ProcessResponse, delegate: ChallengeDelegate)
}

protocol ValidatePhoneNumberRepositoryProtocol {
    func validatePhoneNumber(phoneNumberValidation: PhoneNumberValidation, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)

    func resendPhoneNumberWhenExpired(phoneNumberInformation: PhoneNumberRegistration, onSuccess: @escaping(PhoneNumberRegistrationResponse) -> Void, onFailure: @escaping(ApiError) -> Void)
    
    func resendPhoneNumber(with phoneNumberResendInfo: PhoneNumberResend, processId: String, onSuccess: @escaping (PhoneNumberRegistrationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)

    func callPhoneVerification(verificationID: String, onSuccess: @escaping (PhoneNumberRegistrationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)

    func resendPhoneNumber(phoneNumberResendInfo: PhoneNumberResend, onSuccess: @escaping (PhoneNumberRegistrationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    
    func callPhoneVerification(with phoneCallTransferModel: RequestPhoneCallTransferModel, processId: String, onSuccess: @escaping (PhoneNumberRegistrationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    
    func validatePhoneNumber(phoneNumberValidation: PhoneNumberValidation, processId: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum ValidatePhoneNumberError: Error {
    case incorrectValidationCode(message: String)
    case accountCreationFailed(message: String)
    case callPhoneFailed(message: String)
}

class ValidatePhoneNumberErrorParser: ChallengeErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "nexmo_error" {
            return ApiError.clientError(error: ValidatePhoneNumberError.incorrectValidationCode(message: ""))
        } else if networkError.errorType == "api_sign_up_processor_error" {
             return ApiError.clientError(error: ValidatePhoneNumberError.accountCreationFailed(message: ""))
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
