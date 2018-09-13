//
//  EmailChallengeContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation


protocol EmailChallengeViewProtocol: BaseViewProtocol {
    func updateEmail(with text: String)
    func setProgressBarSteps(currentStep: Int, totalSteps: Int)
    func showClientError(with text: String)
    func hideActivityIndicator(with flag: Bool)
    func showFetchMailError()
}

protocol EmailChallengePresenterProtocol {
    var view: EmailChallengeViewProtocol? { get set }
    func viewWasLoaded()
    func setChallenge(for process: ProcessResponse,with challengeDelegate: ChallengeDelegate)
    func applicationDidBecomeActive()
    func applicationWillEnterForeground()
}

protocol EmailChallengeRepositoryProtocol {
    func requestEmail(with processID:String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func checkEmailValidation(with processID:String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum EmailChallengerError: Error {
    case retryCheckMail
}

class EmailChallengerErrorParser: ChallengeErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == Constants.ApiError.CheckMail.authChallengeNotCompleted {
            return ApiError.clientError(error: EmailChallengerError.retryCheckMail)
        } else {
            return super.getError(networkError: networkError)
        }
    }
}

