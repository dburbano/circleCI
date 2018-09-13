//
//  EmailChallengeRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 5/22/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class EmailChallengeRepository: EmailChallengeRepositoryProtocol {
    
    var apiService: APIServiceProtocol?
    var errorParser: EmailChallengerErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: EmailChallengerErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }
    
    func requestEmail(with processID:String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.request(AuthenticationService.requestMail(processId: processID), onSuccess: { networkResponse in
            do {
                // swiftlint:disable:next force_unwrapping
                let response = try AuthenticationResponse.create(from: networkResponse.body!)
                onSuccess(response)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                onFailure((self.errorParser?.getError(error: error))!)
            }
        }, onError: { responseError in
             onFailure((self.errorParser?.getError(networkError: responseError))!)
        })
    }
    
    func checkEmailValidation(with processID:String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.request(AuthenticationService.getMailVerification(processId: processID), onSuccess: { networkResponse in
            do {
                // swiftlint:disable:next force_unwrapping
                let response = try AuthenticationResponse.create(from: networkResponse.body!)
                onSuccess(response)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                onFailure((self.errorParser?.getError(error: error))!)
            }
        }, onError: { responseError in
            onFailure((self.errorParser?.getError(networkError: responseError))!)
        })
    }
    
}
