//
//  RegisterPhoneNumberRepository.swift
//  machApp
//
//  Created by lukas burns on 3/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class RegisterPhoneNumberRepository: RegisterPhoneNumberRepositoryProcotol {

    var apiService: APIServiceProtocol?
    var errorParser: RegisterPhoneNumberErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: RegisterPhoneNumberErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    internal func registerPhoneNumber(phoneNumberInformation: PhoneNumberRegistration, onSuccess: @escaping (PhoneNumberRegistrationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(PhoneVerificationService.request(parameters: phoneNumberInformation.toParams()),
            onSuccess: { (networkResponse) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let phoneNumberRegistrationResponse = try PhoneNumberRegistrationResponse.create(from: networkResponse.body!)
                    onSuccess(phoneNumberRegistrationResponse)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (responseError) in
                onFailure((self.errorParser?.getError(networkError: responseError))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
    
    internal func verifyPhoneNumber(phoneNumberRegistration: PhoneNumberRegistration, processId: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(AuthenticationService.phoneVerification(parameters: phoneNumberRegistration.toParams(), processId: processId), onSuccess: { networkResponse in
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
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
}
