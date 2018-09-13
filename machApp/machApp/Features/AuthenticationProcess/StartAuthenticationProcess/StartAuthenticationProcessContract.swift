//
//  StartAuthenticationProcessContract.swift
//  machApp
//
//  Created by Santiago Balestero on 8/21/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol StartAuthenticationProcessViewProtocol: BaseViewProtocol {
    func beginAuthenticationProcess(with authenticationResponse: AuthenticationResponse)
    func enableContinueButton()
    func setContinueButtonLoading()
}

protocol StartAuthenticationProcessPresenterProtocol {
    func set(view: StartAuthenticationProcessViewProtocol)
    func startAuthenticationProcessChallenge(goal: AuthenticationGoal)
}

protocol StartAuthenticationProcessRepositoryProtocol {
    func authenticationProcessInit(goal: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

class StartAuthenticationProcessErrorParser: ChallengeErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
