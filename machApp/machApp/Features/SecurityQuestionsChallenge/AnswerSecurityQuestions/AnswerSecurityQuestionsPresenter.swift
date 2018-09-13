//
//  IdentityRecoveryPresenter.swift
//  machApp
//
//  Created by lukas burns on 5/15/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class AnswerSecurityQuestionsPresenter: AnswerSecurityQuestionsPresenterProtocol {

    weak var view: AnswerSecurityQuestionsViewProtocol?
    var repository: AnswerSecurityQuestionsRepositoryProtocol?

    var questionViewModels: [QuestionViewModel] = []
    weak var challengeDelegate: ChallengeDelegate?
    var process: ProcessResponse?
    var requestId: String?
    var questionsId: String?

    required init(repository: AnswerSecurityQuestionsRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: AnswerSecurityQuestionsViewProtocol) {
        self.view = view
    }
    
    func setChallenge(for process: ProcessResponse, challengeDelegate: ChallengeDelegate, securityQuestionsVerificationResponse: SecurityQuestionsVerificationResponse) {
        self.process = process
        self.challengeDelegate = challengeDelegate
        self.questionViewModels = securityQuestionsVerificationResponse.questions.map({ (question) -> QuestionViewModel in
            return QuestionViewModel(question: question, provider: securityQuestionsVerificationResponse.provider)
        })
        self.requestId = securityQuestionsVerificationResponse.requestId
        self.questionsId = securityQuestionsVerificationResponse.questionsId
    }
    
    func viewDidLoad() {
        self.view?.setQuestionViewController(at: 0)
        self.initializeChallenge()
    }
    
    private func initializeChallenge() {
        guard let process = self.process else { return }
        self.view?.setProgressBarSteps(currentStep: process.completedSteps + 1, totalSteps: process.totalSteps + 1)
    }
    
    func getChallengeDelegate() -> ChallengeDelegate? {
        return self.challengeDelegate
    }

    func getQuestionViewModel(at index: Int) -> QuestionViewModel? {
        guard hasQuestionsBeenAnswered(before: index) else {
            // Debes responder la pregunta.
            return nil
        }
        if index < 0 {
            return nil
        } else if index >= questionViewModels.count {
            self.validateAnswers()
        }
        return questionViewModels.get(at: index)
    }

    func hasQuestionsBeenAnswered(before index: Int) -> Bool {
        for (position, question) in questionViewModels.enumerated() {
            if position < index && question.getSelectedOption() == nil {
                return false
            }
        }
        return true
    }

    func validateAnswers() {
        guard let processId = self.process?.id else { return }
        self.view?.showLoadingButton()
        let answers = getAnswers()
        let secufityQuestionsDT = SecurityQuestionsDataTransfer(requestId: self.requestId, questionsId: self.questionsId, answers: answers)
        self.repository?.validateAnswersChallenge(processId: processId,recoverAccount: secufityQuestionsDT, onSuccess: { (authenticationResponse) in
            self.view?.navigateToSecurityQuestionsSuccess(with: authenticationResponse)
            self.view?.hideLoadingButton()
        }, onFailure: { (error) in
            self.handleError(error: error, showDefaultError: true)
            self.view?.hideLoadingButton()
        })
    }

    private func getAnswers() -> [Answer] {
        var answers: [Answer] = []
        for questionViewModel in questionViewModels {
            if let selectedOption = questionViewModel.getSelectedOption() {
                let answer = Answer(questionId: questionViewModel.id, answerId: selectedOption.id)
                answers.append(answer)
            }
        }
        return answers
    }

    func getNumberOfQuestions() -> Int {
        return questionViewModels.count
    }

    private func handleError(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .connectionError():
            self.view?.showNoInternetConnectionError()
        case .serverError(let identityRecoveryError):
            guard let identityRecoveryError = identityRecoveryError as? AnswerSecurityQuestionsError else { return }
            self.view?.showServerError()
            switch identityRecoveryError {
            case .failed(_):
                break
            }
        case .clientError(let identityRecoveryError):
            guard let identityRecoveryError = identityRecoveryError as? AnswerSecurityQuestionsError else { return }

            switch identityRecoveryError {
            case .failed(_):
                break
            }
        case .processFailedError(let errorMessage):
            self.challengeDelegate?.didProcessFailed(errorMessage: errorMessage)
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }

}
