//
//  TEFValidationDepositRepository.swift
//  machApp
//
//  Created by Rodrigo Russell on 18/4/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class TEFValidationInstructionRepository: TEFValidationInstructionRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: TEFValidationInstructionErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: TEFValidationInstructionErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    internal func getLastTEFValidation(onSuccess: @escaping (TEFVerificationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
            apiService?.request(IdentityService.getLastTEFVerification, onSuccess: { (networkResponse) in
                do {
                    let response = try TEFVerificationResponse.create(from: networkResponse.body!)
                    onSuccess(response)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error, with: ["className": String(describing: self), "networkResponse": networkResponse.body ?? ""])
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (networkError) in
                onFailure((self.errorParser?.getError(networkError: networkError))!)
            })
    }
    
}
