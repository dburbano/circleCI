//
//  TEFValidationAmountRepository.swift
//  machApp
//
//  Created by Rodrigo Russell on 16/4/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class TEFValidationAmountRepository: TEFValidationAmountRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: TEFValidationAmountErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: TEFValidationAmountErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    internal func checkVerification(tefVerification: TEFVerificationCheck, processId: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(AuthenticationService.checkTef(parameters: tefVerification.toParams(), processId: processId), onSuccess: { (networkResponse) in
                do {
                    let response = try AuthenticationResponse.create(from: networkResponse.body!)
                    onSuccess(response)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (errorResponse) in
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
    
}
