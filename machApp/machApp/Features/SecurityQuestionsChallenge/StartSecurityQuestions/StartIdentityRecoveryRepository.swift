//
//  StartIdentityRecoveryRepository.swift
//  machApp
//
//  Created by lukas burns on 5/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class StartSecurityQuestionsRepository: StartSecurityQuestionsRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: StartSecurityQuestionsErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: StartSecurityQuestionsErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    internal func getQuestions(processId: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        self.apiService?.request(AuthenticationService.requestSecurityQuestions(processId: processId), onSuccess: { (networkResponse) in
            do {
                //swiftlint:disable:next force_unwrapping
                let authenticationResponse = try AuthenticationResponse.create(from: networkResponse.body!)
                onSuccess(authenticationResponse)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                onFailure((self.errorParser?.getError(error: error))!)
            }
        }, onError: { (networkError) in
            onFailure((self.errorParser?.getError(networkError: networkError))!)
        })
    }
}
