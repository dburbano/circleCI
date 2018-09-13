//
//  IdentityRecoveryRepository.swift
//  machApp
//
//  Created by lukas burns on 5/15/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class AnswerSecurityQuestionsRepository: AnswerSecurityQuestionsRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: AnswerSecurityQuestionsErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: AnswerSecurityQuestionsErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func validateAnswersChallenge(processId: String, recoverAccount: SecurityQuestionsDataTransfer, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
        try self.apiService?.request(AuthenticationService.checkSecurityAnswers(parameters: recoverAccount.toParams(), processId: processId), onSuccess: { (networkResponse) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let response = try AuthenticationResponse.create(from: networkResponse.body!)
                    onSuccess(response)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (networkError) in
                onFailure((self.errorParser?.getError(networkError: networkError))!)
        })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

}
