//
//  TEFValidationAmountContract.swift
//  machApp
//
//  Created by Rodrigo Russell on 16/4/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol TEFValidationAmountViewProtocol: BaseViewProtocol {
    func showIncorrectAmountError()
    func showInputAmounInstruction()
    func showInvalidTefDepositError(for accountNumber: String)
    func enableSendButton()
    func disableSendButton()
    func setSendButtonAsLoading()
    func updateAmountTextField(amount: String)
    func navigateToValidAccountDialogue()
    func navigateToAttemptsDialogueError()
    func disableAmountInput()
    func changeContinueButtonTextForCreateNewVerification()
    func goBackToTEFValidationInstruction()
}

protocol TEFValidationAmountPresenterProtocol: BasePresenterProtocol {
    func setView(view: TEFValidationAmountViewProtocol)
    func setChallenge(with tefVerificationResponse: TEFVerificationResponse, process: ProcessResponse, delegate: ChallengeDelegate)
    func amountChanged(amount: String?)
    func sendVerificationAmount()
    func viewDidLoad()
    func tefDepositFailed()
}

protocol TEFValidationAmountRepositoryProtocol {
   func checkVerification(tefVerification: TEFVerificationCheck, processId: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum TEFValidationAmountError: Error {
    case validationAttemptsLimitReached(message: String)
    case validationAmount(message: String)
}

class TEFValidationAmountErrorParser: ChallengeErrorParser {
    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "identity_tef_verification_too_many_check_attempts_error" {
            return ApiError.clientError(error: TEFValidationAmountError.validationAttemptsLimitReached(message: ""))
        } else if networkError.errorType == "identity_tef_verification_amount_mismatch_error" {
            return ApiError.clientError(error: TEFValidationAmountError.validationAmount(message: ""))
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
