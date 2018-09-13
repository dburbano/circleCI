//
//  IdentityRecoveryContract.swift
//  machApp
//
//  Created by lukas burns on 5/15/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol AnswerSecurityQuestionsViewProtocol: BaseViewProtocol {

    func setQuestionViewController(at index: Int)

    func navigateToSecurityQuestionsSuccess(with authenticationResponse: AuthenticationResponse)

    func showLoadingButton()
    
    func hideLoadingButton()
    
    func setProgressBarSteps(currentStep: Int, totalSteps: Int)

}

protocol AnswerSecurityQuestionsPresenterProtocol: BasePresenterProtocol {

    func setView(view: AnswerSecurityQuestionsViewProtocol)
    
    func setChallenge(for process: ProcessResponse, challengeDelegate: ChallengeDelegate, securityQuestionsVerificationResponse: SecurityQuestionsVerificationResponse)

    func viewDidLoad()
    
    func getChallengeDelegate() -> ChallengeDelegate?
    
    func getQuestionViewModel(at index: Int) -> QuestionViewModel?

    func getNumberOfQuestions() -> Int

}

protocol AnswerSecurityQuestionsRepositoryProtocol {

    func validateAnswersChallenge(processId: String, recoverAccount: SecurityQuestionsDataTransfer, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum AnswerSecurityQuestionsError: Error {
    case failed(message: String)
}

class AnswerSecurityQuestionsErrorParser: ChallengeErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
