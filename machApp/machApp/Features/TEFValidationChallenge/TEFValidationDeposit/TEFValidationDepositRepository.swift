//
//  TEFValidationRepository.swift
//  machApp
//
//  Created by Lukas Burns on 4/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class TEFValidationDepositRepository: TEFValidationDepositRepositoryProtocol {
    
    var apiService: APIServiceProtocol?
    var errorParser: TEFValidationDepositErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: TEFValidationDepositErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    internal func createTEF(cashout: TEFVerification, processId: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(AuthenticationService.requestTef(parameters: cashout.toParams(), processId: processId), onSuccess: { (networkResponse) in
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
