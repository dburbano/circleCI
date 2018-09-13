//
//  RecoverAccountContract.swift
//  machApp
//
//  Created by Lukas Burns on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol RecoverAccountViewProtocol: BaseViewProtocol {
    func showIncorrectRutFormatError()
    func showRutDoesntExistError()
    func hideRutError()
    func enableContinueButton()
    func disableContinueButton()
    func setContinueButtonAsLoading()
    func navigateToAccountAlreadyExists(with authenticationResponse: AuthenticationResponse)
    func navigateToAccountBlocked(with message: String)
    func navigateToAccountRecoverySuccessfull()
    func navigateToAccountRecoveryFailed()
    
}

protocol RecoverAccountPresenterProtocol: BasePresenterProtocol, AuthenticationDelegate {
    func set(view: RecoverAccountViewProtocol)
    func continueButtonPressed()
    func rutEdited(_ text: String?)
    func rutEndEdited()
    func showHelp()
}

protocol RecoverAccountRepositoryProtocol {
    func validateRUTExists(rut: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
     func registerDevice(deviceInformation: DeviceRegistration, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum RecoverAccountError: Error {
    case accountNotFound
}

class RecoverAccountErrorParser: ErrorParser {
    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "api_recover_account_not_found" {
            return ApiError.clientError(error: RecoverAccountError.accountNotFound)
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
