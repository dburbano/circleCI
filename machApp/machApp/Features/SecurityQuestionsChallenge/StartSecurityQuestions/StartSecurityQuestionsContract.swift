//
//  StartIdentityRecoveryContract.swift
//  machApp
//
//  Created by lukas burns on 5/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol StartSecurityQuestionsViewProtocol: BaseViewProtocol {
    func enableButton()
    func disableButton()
    func selectButton()
    func goBackToRegisterDevice()
    func setName(fullName: String)
    func setProgressBarSteps(currentStep: Int, totalSteps: Int)
}

protocol StartSecurityQuestionsPresenterProtocol {
    func setView(view: StartSecurityQuestionsViewProtocol)
    func viewDidLoad()
    func setChallenge(for process: ProcessResponse, challengeDelegate: ChallengeDelegate)
    func startRecoveryPressed()
    func cancelButtonPressed()
}

protocol StartSecurityQuestionsRepositoryProtocol {

    func getQuestions(processId: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum StartSecurityQuestionsError: Error {
    case failed(message: String)
}

class StartSecurityQuestionsErrorParser: ChallengeErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
