//
//  NamePresenter.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/21/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class NamePresenter: NamePresenterProtocol {

    weak var view: NameViewProtocol?
    var repository: NameRepositoryProtocol?

    var firstName: String?
    var lastName: String?
    var email: String?

    required init(repository: NameRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: NameViewProtocol) {
        self.view = view
    }

    func firstNameChanged(firstName: String?) {
        self.firstName = firstName
        validateUserInformation()
    }

    func lastNameChanged(lastName: String?) {
        self.lastName = lastName
        validateUserInformation()
    }

    func emailChanged(email: String?) {
        self.email = email
        validateUserInformation()
        view?.showEmailTakenError(with: true)
    }

    func continueButtonTapped() {
        self.view?.selectedContinueButton()
        trimFields()
        self.registerProfile()
    }
    // MARK: - Private

    private func trimFields() {
        guard let firstName = firstName, let lastName = lastName else {
            fatalError("At this point first name and last name shouldn't be nil")
        }
        self.firstName = firstName.removeLeadingAndTrailingWhitespaces()
        self.lastName = lastName.removeLeadingAndTrailingWhitespaces()
        self.email  = email?.removeLeadingAndTrailingWhitespaces().removeInnerSpaces()
    }

    private func validateUserInformation() {
        let isFirstNameValid = (firstName?.trimmingCharacters(in: .whitespaces).count ?? 0) > 0
        let isLastNameValid = (lastName?.trimmingCharacters(in: .whitespaces).count ?? 0) > 0
        let isEmailValid = email?.isValidEmail() ?? false

        if let email = email, !email.isEmpty, !isEmailValid {
            self.view?.showEmailError()
        } else {
            self.view?.showEmailHint()
        }

        if isFirstNameValid && isLastNameValid && isEmailValid {
            self.view?.enableContinueButton()
        } else {
            self.view?.disableContinueButton()
        }

    }

    private func registerProfile() {
        let userInformation = UserProfile(firstName: firstName, lastName: lastName, birthDate: nil, email: email, imageUrl: nil)
        self.repository?.registerProfile(userInformation: userInformation,
                                         onSuccess: { (userProfileResponse) in
                                            guard let machId = userProfileResponse.machId else {
                                                print("ERROR GRAVISIMO NO ME LLEGO UN MACH ID!!!!")
                                                return
                                            }
                                            print("Mi Mach ID es: \(machId)")
                                            AccountManager.sharedInstance.set(machId: machId)
                                            Thread.runOnMainQueue(1, completion: {
                                                self.view?.enableContinueButton()
                                            })
                                            let userInfo = [
                                                SegmentAnalytics.Trait.firstName.rawValue: userProfileResponse.firstName,
                                                SegmentAnalytics.Trait.lastName.rawValue: userProfileResponse.lastName,
                                                SegmentAnalytics.Trait.email.rawValue: userProfileResponse.email
                                            ]
                                            SegmentManager.sharedInstance.identifyAnonymousUser(traits: userInfo as! [String : String])
                                            SegmentAnalytics.Event.profileUpdated(
                                                email: userProfileResponse.email!,
                                                firstName: userProfileResponse.firstName,
                                                lastName: userProfileResponse.lastName,
                                                location: SegmentAnalytics.EventParameter.LocationType().registration
                                            ).track()
                                            self.view?.navigateToProfilePhoto()
                                            UserCacheManager.sharedInstance.userProfile = userProfileResponse
        }, onFailure: { (error) in
            self.view?.enableContinueButton()
            self.handle(error: error)
        })
    }

    private func handle(error apiError: ApiError) {
        switch apiError {
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let registerProfileError):
            guard let registerProfileError = registerProfileError as? RegisterProfileError else { return }
            self.view?.showServerError()
            switch registerProfileError {
            case .failed:
                break
            case .emailTaken:
                 view?.showEmailTakenError(with: false)
            case .mailNotValid:
                view?.showEmailError()
            }
        case .clientError(let registerProfileError):
            guard let registerProfileError = registerProfileError as? RegisterProfileError else { return }
            switch registerProfileError {
            case .failed:
                self.view?.showServerError()
            case .emailTaken:
                view?.showEmailTakenError(with: false)
            case .mailNotValid:
                view?.showEmailError()
            }
        default:
            self.view?.showServerError()
        }
    }
}
