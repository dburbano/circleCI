//
//  CreateAccountContract.swift
//  machApp
//
//  Created by Lukas Burns on 5/25/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

/*
 Contract File
 Remember to Inject in Injections
 
 Copy this to injection file
 
 */

import Foundation

protocol CreateAccountViewProtocol: BaseViewProtocol {
    func navigateToGeneratePINNumber()
}

protocol CreateAccountPresenterProtocol: BasePresenterProtocol {
    func set(view: CreateAccountViewProtocol)
    
    func createAccount()
    
    func applicationDidBecomeActive()
    
    func applicationWillEnterForeground()

}

protocol CreateAccountRepositoryProtocol {
     func createAccount(onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum CreateAccountError: Error {
    case accountAlreadyPendingIssuingProcess(message: String)
    case accountAlreadyFinishedIssuingProcess(message: String)
}

class CreateAccountErrorParser: ErrorParser {
    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "account_already_pending_issuing_process" {
            return ApiError.clientError(error: CreateAccountError.accountAlreadyPendingIssuingProcess(message: ""))
        } else if networkError.errorType == "account_already_finished_issuing_process" {
            return ApiError.clientError(error: CreateAccountError.accountAlreadyFinishedIssuingProcess(message: ""))
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
