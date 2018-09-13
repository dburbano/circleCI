//
//  EmailChallengePresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class EmailChallengePresenter: EmailChallengePresenterProtocol {
    
    var process: ProcessResponse?
    weak var view: EmailChallengeViewProtocol?
    weak var challengeDelegate: ChallengeDelegate?
    var repository: EmailChallengeRepositoryProtocol?
    var retryCheckMail: Bool = false
    
    //Request
    let requestEmailNumberRetries = 2
    var requestRetryCounter = 0
    
    //Check Mail
    var checkMailNumberRetries = 2
    var checkRetryCounter = 0
    
    //CheckMail Timmer
    var checkMailTimeToTrigger = 45.0
    var checkMailTimer: Timer?
    
    required init(repository: EmailChallengeRepositoryProtocol?) {
        self.repository = repository
    }
    
    func viewWasLoaded() {
        setProgressBar()
        requestEmail()
    }
    
    func setChallenge(for process: ProcessResponse,with challengeDelegate: ChallengeDelegate) {
        self.process = process
        self.challengeDelegate = challengeDelegate
    }
    
    private func setProgressBar() {
        if let process = process {
            view?.setProgressBarSteps(currentStep: process.completedSteps + 1, totalSteps: process.totalSteps + 1)
        }
    }
    
    private func requestEmail() {
        if let process = process {
            view?.hideActivityIndicator(with: false)
            repository?.requestEmail(with: process.id, onSuccess: {[weak self] authenticationResponse in
                self?.handleRequestMailResponse(with: authenticationResponse)
                self?.view?.hideActivityIndicator(with: true)
                //We need to start a timer in case for some reason we don't receive the pubNub message
                self?.startCheckMailTimer()
                }, onFailure: {[weak self] error in
                    self?.requestRetryCounter += 1
                    guard let counter = self?.requestRetryCounter,
                        let retryTimes = self?.requestEmailNumberRetries,
                        counter < retryTimes
                        else {
                            self?.view?.showFetchMailError()
                            self?.view?.hideActivityIndicator(with: true)
                            return
                    }
                    self?.requestEmail()
            })
        }
    }
    
    private func handleRequestMailResponse(with response: AuthenticationResponse) {
        self.listenForEmailValidated()
        guard let challenge = response.challenge?.challenge else { return }
        switch challenge {
        case .checkEmail(let emailResponse):
            setEmail(with: emailResponse.email)
            process = response.process
            setProgressBar()
        default:
            break
        }
    }
    
    private func setEmail(with text: String) {
        let splittedText = text.split("@")
        guard let leftSide = splittedText.first,
            let rightSide = splittedText.last else { return }
        let response = "\(leftSide.convertEndOfWord(with: "*", percentage: 0.5))@\(rightSide.convertBeginingOfWord(with: "@", percentage: 0.6))"
        view?.updateEmail(with: response)
    }
    
    //This method should be triggered when a pubNub is received.
    private func checkEmail() {
        if let process = process {
            view?.hideActivityIndicator(with: false)
            repository?.checkEmailValidation(with: process.id, onSuccess: {[weak self] authenticationResponse in
                NotificationManager.sharedInstance.stop()
                NotificationCenter.default.removeObserver(self as Any)
                self?.view?.hideActivityIndicator(with: true)
                self?.challengeDelegate?.didSucceedChallenge(authenticationResponse: authenticationResponse)
                self?.cancelCheckMailTimer()
                }, onFailure: {[weak self] error in
                    self?.view?.hideActivityIndicator(with: true)
                    self?.handle(error: error)
            })
        }
    }
    
    private func handle(error: ApiError) {
        switch error {
        case .connectionError:
            view?.showNoInternetConnectionError()
        case .serverError:
            view?.showServerError()
        case .clientError(let checkMailError):
             guard let error = checkMailError as? EmailChallengerError
                else {
                    view?.showClientError(with: "Ha ocurrido un error")
                    return }
             switch error {
             case .retryCheckMail:
               handleRetryCheckMail()
                return
            }
        case .processFailedError(let errorMessage):
            self.challengeDelegate?.didProcessFailed(errorMessage: errorMessage)
        default:
            view?.showServerError()
        }
    }
    
    private func handleRetryCheckMail() {
        checkRetryCounter += 1
        if checkRetryCounter <= checkMailNumberRetries {
            let delay = checkRetryCounter == 1 ? 5.0 : 2.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {[weak self] in
                self?.checkEmail()
            }
        } else {
            view?.showClientError(with: "Ha ocurrido un error")
        }
    }
    
    private func startCheckMailTimer() {
        checkMailTimer = Timer.scheduledTimer(timeInterval: 1,
                                              target: self,
                                              selector: (#selector(updateTimeToTriggerCheckMail)),
                                              userInfo: nil,
                                              repeats: true)
    }
    
    private func cancelCheckMailTimer() {
        checkMailTimer?.invalidate()
    }
    
    @objc func updateTimeToTriggerCheckMail() {
        checkMailTimeToTrigger -= 1.0
        print(checkMailTimeToTrigger)
        if checkMailTimeToTrigger <= 0 {
            cancelCheckMailTimer()
            checkEmail()
        }
    }

    private func listenForEmailValidated() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(EmailChallengePresenter.emailValidated(notification:)), name: .EmailChallengeCompleted, object: nil)
        NotificationManager.sharedInstance.stop()
        Thread.runOnMainQueue(1.0) {
            NotificationManager.sharedInstance.startListeningForMessages()
        }
    }

    @objc func emailValidated(notification: Notification) {
        self.checkEmail()
    }

    func applicationDidBecomeActive() {
        self.listenForEmailValidated()
    }

    func applicationWillEnterForeground() {
        self.listenForEmailValidated()
    }
}
