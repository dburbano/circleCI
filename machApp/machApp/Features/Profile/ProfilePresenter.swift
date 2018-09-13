//
//  ProfilePresenter.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/25/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class ProfilePresenter: ProfilePresenterProtocol {

    weak var view: ProfileViewProtocol?
    var repository: ProfileRepositoryProtocol?

    var firstName: String?
    var lastName: String?
    var email: String?
    var data: Data?
    var user: User?

    required init(repository: ProfileRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: ProfileViewProtocol) {
        self.view = view
        NotificationCenter.default.addObserver(self, selector: #selector(ProfilePresenter.didUpdateProfile), name: .ProfileDidUpdate, object: nil)
    }

    func firstNameChanged(firstName: String?) {
        self.firstName = firstName
        validateFields()
    }

    func lastNameChanged(lastName: String?) {

        self.lastName = lastName
        validateFields()
    }

    func validateFields() {
        guard let firstName = self.firstName, !firstName.isEmpty, firstName.count >= 1, !firstName.trimmingCharacters(in: .whitespaces).isEmpty,
            let lastName = self.lastName, !lastName.isEmpty, lastName.count >= 1, !lastName.trimmingCharacters(in: .whitespaces).isEmpty,
            let mail = self.email, isValidEmail(testStr: mail), !mail.isEmpty else {
                self.view?.disableReadyButton()
                return
        }

        if (firstName != user?.firstName || lastName != user?.lastName) || mail != user?.email {
            self.view?.enableReadyButton()
        } else {
            self.view?.disableReadyButton()
        }
    }

    // Email
    func emailChanged(email: String?) {
        self.email = email
        validateFields()
        view?.showValidatedMail(with: .blankState)
    }

    func setupUser() {
        guard let user = AccountManager.sharedInstance.getUser() else { return }
        self.user = user
        firstName = user.firstName
        lastName = user.lastName
        email = user.email
        let userViewModel = UserViewModel(user: user)
        self.view?.setFirstName(firstName: userViewModel.machFirstName)
        self.view?.setLastName(lastName: userViewModel.machLastName)
        self.view?.setEmail(email: userViewModel.email)
        self.view?.setImage(image: UserPhotoManager.sharedInstance.getProfileImage(), imageURL: userViewModel.profileImageUrl, placeholderImage: userViewModel.profileImage)
    }

    private func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    private func saveUserInfo(with remoteUser: UserProfileResponse) {
        //Make sure we only save what's new
        guard let user = AccountManager.sharedInstance.getUser() else { return }
        
        if let savedFirstName = user.firstName, remoteUser.firstName != savedFirstName {
            AccountManager.sharedInstance.updateFirstName(firstName: firstName)
        }
        if let savedLastName = user.lastName, remoteUser.lastName != savedLastName {
            AccountManager.sharedInstance.updateLastName(lastName: lastName)
        }
        if let savedEmail = user.email, remoteUser.email != savedEmail {
            AccountManager.sharedInstance.updateEmail(email: email)
            AccountManager.sharedInstance.updateEmailValidated(with: remoteUser.emailConfirmedAt)
            //We send a notification here so that the views that show any kind of icon regarding the mail validation update themselves
            NotificationCenter.default.post(name: .ProfileDidUpdate, object: nil)
        }
    }

    func imageChosen(data: Data?) {
        self.view?.enableReadyButton()
        self.data = data
    }

    // Photo
    internal func uploadProfileImage() {
        guard let image = self.data else { return }
        UserPhotoManager.sharedInstance.saveProfileImage(imageData: image)
        self.view?.disableReadyButton()
        self.repository?.uploadImage(image: image, onSuccess: { (imageUploadResponse) in
            if let images = imageUploadResponse.images {
                AccountManager.sharedInstance.updateProfileImage(images: images)
            }
            print ("Imagen subida con exito")
        }, onFailure: { (uploadError) in
            self.handle(error: uploadError)
        })
    }

    internal func updateProfile() {

        firstName = firstName?.removeLeadingAndTrailingWhitespaces().removeInnerSpaces()
        lastName = lastName?.removeLeadingAndTrailingWhitespaces().removeInnerSpaces()

        let userInfo = UserProfile(firstName: self.firstName, lastName: self.lastName, birthDate: nil, email: self.email, imageUrl: nil)
        self.view?.selectReadyButton()
        self.repository?.updateProfile(userInformation: userInfo, onSuccess: {[weak self] remoteUser in
            self?.saveUserInfo(with: remoteUser)
            self?.view?.enableReadyButton()
            self?.view?.disableReadyButton()
        }, onFailure: { (networkError) in
            self.view?.enableReadyButton()
            self.handle(error: networkError)
        })
    }
    
    func didPressSave() {
        guard let user = AccountManager.sharedInstance.getUser(),
            let savedEmail = user.email,
            let currentMail = email,
            savedEmail != currentMail && user.emailConfirmedAt != nil  else {
            uploadProfileImage()
            updateProfile()
            return
        }
        view?.showMailUpdateOverlay()
    }

    func isUsersMailValidated() {
        isEmailValidated {[weak self] (response) in
            self?.view?.showValidatedMail(with: response ? .validated : .notValidated)
        }
    }

    func validateEmail() {
        repository?.validateMail(onSuccess: {[weak self] in
            self?.view?.showValidatedMail(with: .validationInProgress)
            }, onFailure: {[weak self] error in
                self?.handle(error: error)
        })
    }

    private func isEmailValidated(response: @escaping (Bool) -> Void) {
        guard let repository = repository else {
            response(false)
            return
        }
        repository.isUsersMailValidated { flag in
            response(flag)
        }
    }

    // Private

    //swiftlint:disable:next cyclomatic_complexity
    private func handle(error apiError: ApiError) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            view?.showNoInternetConnectionError()
        case .serverError(let profileError):
            guard let profileError = profileError as? ProfileError else { return }
            self.view?.showServerError()
            switch profileError {
            case .failed, .uploadImageFailed:
                self.view?.showServerError()
            case .emailTaken:
                view?.showValidatedMail(with: .takenEmail)
            case .emailValidated:
                view?.showValidatedMail(with: .validated)
            }
        case .clientError(let profileError):
            guard let profileError = profileError as? ProfileError else { return }

            switch profileError {
            case .failed:
                self.view?.showServerError()
            case .uploadImageFailed:
                self.view?.showServerError()
            case .emailTaken:
                view?.showValidatedMail(with: .takenEmail)
                view?.disableReadyButton()
            case .emailValidated:
                view?.showValidatedMail(with: .validated)
            }
        default:
            self.view?.showServerError()
        }
    }

    @objc func didUpdateProfile() {
        isUsersMailValidated()
    }
}
