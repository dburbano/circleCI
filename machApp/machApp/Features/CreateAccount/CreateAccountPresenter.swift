//
//  CreateAccountPresenter.swift
//  machApp
//
//  Created by Lukas Burns on 5/25/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class CreateAccountPresenter {
    
    weak var view: CreateAccountViewProtocol?
    var repository: CreateAccountRepositoryProtocol?
    
    init(repository: CreateAccountRepositoryProtocol?) {
        self.repository = repository
    }

    // MARK: - Private Function
    
    @objc func accountCreated(notification: Notification) {
        NotificationManager.sharedInstance.stop()
        NotificationCenter.default.removeObserver(self)
        self.accountCreationSuccessfull()
    }
    
    
    func accountCreationSuccessfull() {
        Thread.runOnMainQueue(3.0, completion: {
            if AccountManager.sharedInstance.isAccountCreationInProcess() {
                AccountManager.sharedInstance.setIsAccountCreationInProcess(with: false)
                self.view?.navigateToGeneratePINNumber()
            }
        })
    }
    
    func listenForAccountCreation() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateAccountPresenter.accountCreated(notification:)), name: .AccountCreated, object: nil)
        NotificationManager.sharedInstance.stop()
        NotificationManager.sharedInstance.startListeningForMessages()
    }
}

extension CreateAccountPresenter: CreateAccountPresenterProtocol {

    func set(view: CreateAccountViewProtocol) {
        self.view = view
    }
    
    func createAccount() {
        AccountManager.sharedInstance.setIsAccountCreationInProcess(with: true)
        self.repository?.createAccount(onSuccess: {
            self.listenForAccountCreation()
        }, onFailure: { (error) in
            switch error {
            case .clientError(let createAccountError):
                guard let createAccountError = createAccountError as? CreateAccountError else { return }
                switch createAccountError {
                case .accountAlreadyPendingIssuingProcess:
                    self.listenForAccountCreation()
                case .accountAlreadyFinishedIssuingProcess:
                    self.accountCreationSuccessfull()
                }
            default:
                break
            }}
        )
    }
    
    func applicationDidBecomeActive() {
        self.listenForAccountCreation()
    }
    
    func applicationWillEnterForeground() {
        self.listenForAccountCreation()
    }

}
