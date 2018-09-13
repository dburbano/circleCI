//
//  MorePresenter.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/18/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class MorePresenter: MorePresenterProtocol {

    //Section ID's
    fileprivate let firstSectionID: Int = 0
    fileprivate let secondSectionID: Int = 1
    fileprivate let thirdSectionID: Int = 2

    //Row ID's
    //First Section
    fileprivate let cashoutID: Int = 0
    fileprivate let inviteID: Int = 1

    //Second Section
    fileprivate let changePinID: Int = 0

    //Third Section
    fileprivate let getInTouchID: Int = 0
    fileprivate let termsAndConditionsID: Int = 1

    weak var view: MoreViewProtocol?
    var repository: MoreRepositoryProtocol?

    required init(repository: MoreRepositoryProtocol?) {
        self.repository = repository
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: MorePresenterProtocol
    func setView(view: MoreViewProtocol) {
        self.view = view
        NotificationCenter.default.addObserver(self, selector: #selector(MorePresenter.didUpdateProfile), name: .ProfileDidUpdate, object: nil)
    }

    func profileButtonTapped() {
        self.view?.navigateToProfile()
    }

    func setUserInfo() {
        guard let user = AccountManager.sharedInstance.getUser() else { return }
        let userViewModel = UserViewModel(user: user)
        self.view?.setUserName(userName: userViewModel.machFirstName + " " + userViewModel.machLastName)
        self.view?.setEmail(email: userViewModel.email)
        self.view?.setImage(image: UserPhotoManager.sharedInstance.getProfileImage(), imageURL: userViewModel.profileImageUrl, placeholderImage: userViewModel.profileImage)
    }

    func isUsersMailValidated() {
        repository?.isUsersMailValidated(response: {[weak self] response in
            if let nonValidatedImage = UIImage(named: "iconSecurityAlertPerfil"),
                let validatedImage = UIImage(named: "iconSecurityCheckPerfil") {
                if response {
                    self?.view?.showValidatedMail(with: validatedImage)
                } else {
                    self?.view?.showValidatedMail(with: nonValidatedImage)
                }
            }
        })
    }

    @objc func didUpdateProfile() {
        isUsersMailValidated()
    }
}
