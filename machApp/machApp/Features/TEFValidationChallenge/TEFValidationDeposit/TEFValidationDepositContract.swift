//
//  TEFValidationDepositContract.swift
//  machApp
//
//  Created by Lukas Burns on 4/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol TEFValidationDepositViewProtocol: BaseViewProtocol {
    func enableButton()
    func disableButton()
    func set(bankName: String)
    func reloadBanks()
    func setSelectedBank(at index: Int)
    func set(accountNumber: String)
    func set(name: String)
    func set(rut: String)
    func navigateToTooManyAttemptsDialogue()
    func navigateToTooManyConsecutiveCreateErrorDialogue()
}

protocol TEFValidationDepositPresenterProtocol: BasePresenterProtocol {
    func setView(view: TEFValidationDepositViewProtocol)
    func setChallenge(with banks: [Bank], process: ProcessResponse, delegate: ChallengeDelegate)
    func viewDidLoad()
    func bankSelected(at row: Int)
    func getBankName(at row: Int) -> String
    func getNumberOfBanks() -> Int
    func accountNumberEdited(account: String?)
    func sendTEF(accountNumber: String)
    func cleanAccountNumber(account: String) -> String
}

protocol TEFValidationDepositRepositoryProtocol {
    func createTEF(cashout: TEFVerification, processId: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum TEFValidationDepositError: Error {
    case tooManyTEFCreations(message: String)
    case tooManyCheckAttempts(message: String)
    case tooManyConsecutiveCreate(message: String)
}

class TEFValidationDepositErrorParser: ChallengeErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "identity_tef_verification_too_many_create_attempts_error" {
            return ApiError.clientError(error: TEFValidationDepositError.tooManyTEFCreations(message: ""))
        } else if networkError.errorType == "identity_tef_verification_too_many_check_attempts_error" {
            return ApiError.clientError(error: TEFValidationDepositError.tooManyCheckAttempts(message: ""))
        }  else if networkError.errorType == "identity_tef_verification_too_many_consecutive_create_error" {
            return ApiError.clientError(error: TEFValidationDepositError.tooManyConsecutiveCreate(message: ""))
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
