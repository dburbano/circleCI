//
//  TEFValidationInstructionContract.swift
//  machApp
//
//  Created by Lukas Burns on 4/10/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol TEFValidationInstructionViewProtocol: BaseViewProtocol {
    func setStartButtonAsActive()
    func setStartButtonAsDisabled()
    func setStartButtonAsLoading()
    func setCheckboxAsSelected()
    func setCheckboxAsUnselected()
    func navigateToTEFValidationDeposit()
    func navigateToTEFValidationAmount(tefVerificationViewModel: TEFVerificationViewModel)
}

protocol TEFValidationInstructionPresenterProtocol: BasePresenterProtocol {
    var areInstructionsUnderstood: Bool { get set }
    func setView(view: TEFValidationInstructionViewProtocol)
    func understandInstructionCheckboxPressed()
    func getLastTEFValidation()
    func setup()
}

protocol TEFValidationInstructionRepositoryProtocol {
    func getLastTEFValidation(onSuccess: @escaping (TEFVerificationResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum TEFValidationInstructionError: Error {
    case noTefVerificationFound(message: String)
}

class TEFValidationInstructionErrorParser: ErrorParser {
    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "identity_tef_verification_not_found_error" {
            return ApiError.clientError(error: TEFValidationInstructionError.noTefVerificationFound(message: ""))
        }
        return super.getError(networkError: networkError)
    }
}
