//
//  NameContract.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/21/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol NameViewProtocol: BaseViewProtocol {
    func navigateToProfilePhoto()
    func enableContinueButton()
    func disableContinueButton()
    func selectedContinueButton()
    func showEmailError()
    func showEmailHint()
    func showEmailTakenError(with flag: Bool)
}

protocol NamePresenterProtocol: BasePresenterProtocol {
    var firstName: String? { get }
    var lastName: String? { get }
    func setView(view: NameViewProtocol)
    func firstNameChanged(firstName: String?)
    func lastNameChanged(lastName: String?)
    func emailChanged(email: String?)
    func continueButtonTapped()
}

protocol NameRepositoryProtocol {
    func registerProfile(userInformation: UserProfile, onSuccess: @escaping (UserProfileResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum RegisterProfileError: Error {
    case failed(message: String)
    case emailTaken
    case mailNotValid(message: String)
}

class RegisterProfileErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "email_verification_email_taken_validation_error" {
            return ApiError.clientError(error: RegisterProfileError.emailTaken)
        } else if networkError.errorType == "email_verification_verify_email_validation_error" {
            return ApiError.clientError(error: RegisterProfileError.mailNotValid(message: "El correo que has ingresado no es válido"))
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
