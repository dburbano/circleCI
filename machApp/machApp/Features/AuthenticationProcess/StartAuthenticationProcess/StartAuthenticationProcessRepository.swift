//
//  StartAuthenticationProcessRepository.swift
//  machApp
//
//  Created by Santiago Balestero on 8/21/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class StartAuthenticationProcessRepository: StartAuthenticationProcessRepositoryProtocol {
 
    var apiService: APIServiceProtocol?
    var errorParser: StartAuthenticationProcessErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: StartAuthenticationProcessErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }
    
    internal func authenticationProcessInit(goal: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.request(AuthenticationService.getAuthenticationProcess(authenticationGoal: goal), onSuccess: { networkResponse in
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
