//
//  StartIdentityRecoveryPresenter.swift
//  machApp
//
//  Created by lukas burns on 5/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class StartSecurityQuestionsPresenter: StartSecurityQuestionsPresenterProtocol {

    weak var view: StartSecurityQuestionsViewProtocol?
    var repository: StartSecurityQuestionsRepositoryProtocol?
    
    var process: ProcessResponse?
    weak var challengeDelegate: ChallengeDelegate?

    var questionsViewModel: [QuestionViewModel] = []
    var questionsId: String?
    var requestId: String?
    var userIdentity: UserIdentityVerificationInformation?
    var fullName: String?

    required init(repository: StartSecurityQuestionsRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: StartSecurityQuestionsViewProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        self.view?.setName(fullName: fullName ?? "")
        self.initializeChallenge()
    }
    
    func setChallenge(for process: ProcessResponse, challengeDelegate: ChallengeDelegate) {
        self.process = process
        self.challengeDelegate = challengeDelegate
    }
    
    private func initializeChallenge() {
        guard let process = self.process else { return }
        self.view?.setProgressBarSteps(currentStep: process.completedSteps + 1, totalSteps: process.totalSteps + 1)
    }

    func startRecoveryPressed() {
        guard let processId = self.process?.id else { return }
        self.view?.selectButton()
        self.repository?.getQuestions(processId: processId, onSuccess: { (authenticationResponse) in
            self.challengeDelegate?.didSucceedChallenge(authenticationResponse: authenticationResponse)
        }, onFailure: { (error) in
            self.view?.enableButton()
            self.handleError(error: error)
        })
    }

    func cancelButtonPressed() {
        self.view?.goBackToRegisterDevice()
    }

    private func handleError(error apiError: ApiError) {
        switch apiError {
        case .connectionError():
            break
        case .serverError(let startSecurityQuestionsError):
            guard let startSecurityQuestionsError = startSecurityQuestionsError as? StartSecurityQuestionsError else { return }
            switch startSecurityQuestionsError {
            case .failed:
                break
            }
        case .clientError(let startSecurityQuestionsError):
            guard let startSecurityQuestionsError = startSecurityQuestionsError as? StartSecurityQuestionsError else { return }
            switch startSecurityQuestionsError {
            case .failed:
                break
            }
        case .processFailedError(let errorMessage):
            self.challengeDelegate?.didProcessFailed(errorMessage: errorMessage)
        default:
            break
        }
    }
}
