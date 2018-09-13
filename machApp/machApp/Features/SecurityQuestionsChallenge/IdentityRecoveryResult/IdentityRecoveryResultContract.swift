//
//  IdentityRecoveryResultContract.swift
//  machApp
//
//  Created by lukas burns on 5/18/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol IdentityRecoveryResultViewProtocol: BaseViewProtocol {

    func setupViewAsResultSuccess(with title: String, message: String, buttonMessage: String, imageName: String)

    func setupViewAsResultBlocked(with title: String, message: NSMutableAttributedString, buttonMessage: String, imageName: String)

    func setupViewAsResultFailed(with title: String, message: String, buttonMessage: String, imageName: String)

    func setupViewAsResultTooManyAttempts(with title: String, message: String, buttonMessage: String, imageName: String)

    func navigateToStartIdentityRecovery()

    func navigateToHome()

}

protocol IdentityRecoveryResultPresenterProtocol {
    
    var userViewModel: UserViewModel? { get set }

    func setView(view: IdentityRecoveryResultViewProtocol)

    func setupResultStatus(identityRecoveryResultStatus: IdentityRecoveryResultStatus?)

    func continueButtonPressed()
}

protocol IdentityRecoveryResultRepositoryProtocol {

}
