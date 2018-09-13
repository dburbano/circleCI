//
//  RegisterUserContract.swift
//  machApp
//
//  Created by lukas burns on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol VerifyUserViewProtocol: BaseViewProtocol {
    func navigateToStartIdentityRecovery(userViewModel: UserViewModel)
    func navigateToPhoneNumberRegistration()
    func showRutError()
    func hideRutError()
    func hideBackButtonIfNeeded(processGoal: String)
    func enableContinueButton()
    func disableContinueButton()
    func setContinueButtonAsLoading()
    func showIncorrectNumbersError()
    func showBlockedError()
    func showAccountAlreadyExistError()
    func showAccountDoesntExistError()
    func showUnderAgeError()
    func hideSerialNumberError()
    func presentCIInformation()
    func setRutTextField(with text: String)
    func showNotTrustedSourceError(with message: String)
    func disableRutTextField()
    func setProgressBarSteps(currentStep: Int, totalSteps: Int)
    func setSerialNumberAsFirstResponder()
    func navigateToStartRecoverAccount(with rut: String?)
}

protocol VerifyUserPresenterProtocol: BasePresenterProtocol {
    func verifyUserIdentity()
    func setView(view: VerifyUserViewProtocol)
    func viewDidLoad(_ accountMode: AccountMode?)
    func setChallenge(for process: ProcessResponse, with rut: String, challengeDelegate: ChallengeDelegate)
    func rutEdited(_ text: String?)
    func rutEndEdited()
    func serialNumberEdited(_ text: String?)
    func serialNumberEndEdited()
    func showMoreInformation()
    func getUserIdentityInformation() -> UserIdentityVerificationInformation

}

protocol VerifyUserRepositoryProtocol {
    func verifyUserIdentity(userInformation: UserIdentityVerificationInformation, onSuccess: @escaping (VerifyUserResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func verifyDocumentIdChallenge(processId: String, userInformation: UserIdentityVerificationInformation, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func registerDevice(deviceInformation: DeviceRegistration, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum VerifyUserError: Error {
    case rutAndSerialNumberValidationFailed(message: String)
    case underAgeError(message: String)
    case invalidRut(message: String)
    case notTrustedSource(message: String)
    case userAlreadyRegistered(message: String)
}

class VerifyUserErrorParser: ChallengeErrorParser {
    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "sinacofi_invalid_rut" {
            return ApiError.clientError(error: VerifyUserError.invalidRut(message: ""))
        } else if networkError.errorType == "sinacofi_unable_to_authenticate_rut" {
            return ApiError.clientError(error: VerifyUserError.rutAndSerialNumberValidationFailed(message: ""))
        } else if networkError.errorType == "sinacofi_underaged_user" {
            return ApiError.clientError(error: VerifyUserError.underAgeError(message: ""))
        } else if networkError.errorType == "sinacofi_not_trusted_source_error" {
            return ApiError.clientError(error: VerifyUserError.notTrustedSource(message: networkError.errorMessage ?? ""))
        } else if networkError.errorType == "api_sign_up_account_already_exists" {
            return ApiError.clientError(error: VerifyUserError.userAlreadyRegistered(message: networkError.errorMessage ?? ""))
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
