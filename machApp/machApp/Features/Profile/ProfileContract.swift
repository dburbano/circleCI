//
//  ProfileContract.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/25/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileViewProtocol: BaseViewProtocol {
    func navigateBackToMore()
    func enableReadyButton()
    func disableReadyButton()
    func selectReadyButton()
    func setFirstName(firstName: String?)
    func setLastName(lastName: String?)
    func setEmail(email: String?)
    func setImage(image: UIImage?, imageURL: URL?, placeholderImage: UIImage?)
    func showValidatedMail(with status: ValidateMailStages)
    func showMailUpdateOverlay()
}

protocol ProfilePresenterProtocol: BasePresenterProtocol {
    func setView(view: ProfileViewProtocol)
    func setupUser()
    func uploadProfileImage()
    func updateProfile()
    func firstNameChanged(firstName: String?)
    func lastNameChanged(lastName: String?)
    func emailChanged(email: String?)
    func imageChosen(data: Data?)
    func isUsersMailValidated()
    func validateEmail()
    func didPressSave()
}

protocol ProfileRepositoryProtocol {
    func uploadImage(image: Data, onSuccess: @escaping (ImageUploadResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func updateProfile(userInformation: UserProfile, onSuccess: @escaping (UserProfileResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func isUsersMailValidated(response: (Bool) -> Void)
    func validateMail(onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum ProfileError: Error {
    case failed(message: String)
    case uploadImageFailed(message: String)
    case emailTaken
    case emailValidated
}

enum ValidateMailStages {
    case notValidated
    case validated
    case validationInProgress
    case takenEmail
    case blankState
}

class ProfileErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "cash_in_webpay_oneclick_card_error" ||
            networkError.errorType == "email_verification_email_taken_validation_error" {
            return ApiError.clientError(error: ProfileError.emailTaken)
        } else if networkError.errorType == "email_verification_email_confirmed_validation_error" {
            return ApiError.clientError(error: ProfileError.emailValidated)
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
