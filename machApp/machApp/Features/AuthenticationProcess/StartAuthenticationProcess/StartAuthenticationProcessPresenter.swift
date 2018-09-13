//
//  StartAuthenticationProcessPresenter.swift
//  machApp
//
//  Created by Santiago Balestero on 8/21/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class StartAuthenticationProcessPresenter: StartAuthenticationProcessPresenterProtocol {

    var goal: AuthenticationGoal?
    var repository: StartAuthenticationProcessRepositoryProtocol?
    weak var challengeDelegate: ChallengeDelegate?
    weak var view: StartAuthenticationProcessViewProtocol?
    
    required init(repository: StartAuthenticationProcessRepositoryProtocol?) {
        self.repository = repository
    }
    
    func set(view: StartAuthenticationProcessViewProtocol) {
        self.view = view
    }
    
    func startAuthenticationProcessChallenge(goal: AuthenticationGoal) {
        self.view?.setContinueButtonLoading()
        repository?.authenticationProcessInit(goal: goal.rawValue, onSuccess: { [weak self] authenticationResponse in
            self?.view?.beginAuthenticationProcess(with: authenticationResponse)
            self?.view?.enableContinueButton()
            }, onFailure: {[weak self] error in
                self?.view?.enableContinueButton()
                self?.handle(error: error)
        })
    }
     
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            break
        case .serverError(let cashInError):
            break
        case .clientError(let cashInError):
            break
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
}
