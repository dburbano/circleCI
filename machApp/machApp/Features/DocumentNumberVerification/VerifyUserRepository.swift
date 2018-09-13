//
//  RegisterUserRepository.swift
//  machApp
//
//  Created by lukas burns on 3/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class VerifyUserRepository: VerifyUserRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: VerifyUserErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: VerifyUserErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    internal func verifyUserIdentity(userInformation: UserIdentityVerificationInformation, onSuccess: @escaping (VerifyUserResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(IdentityService.verify(parameters: userInformation.toParams()),
            onSuccess: { (networkResponse) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let verifyUserResponse = try VerifyUserResponse.create(from: networkResponse.body!)
                    onSuccess(verifyUserResponse)
                } catch {
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            },
            onError: { (errorResponse) in
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })

        } catch {
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
    
    internal func verifyDocumentIdChallenge(processId: String, userInformation: UserIdentityVerificationInformation, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(AuthenticationService.verifyIdDocument(parameters: userInformation.toParams(), processId: processId),
                                    onSuccess: { (networkResponse) in
                                        do {
                                            //swiftlint:disable:next force_unwrapping
                                            let authenticationResposne = try AuthenticationResponse.create(from: networkResponse.body!)
                                            onSuccess(authenticationResposne)
                                        } catch {
                                            onFailure((self.errorParser?.getError(error: error))!)
                                        }
            },
                                    onError: { (errorResponse) in
                                        onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
            
        } catch {
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
    
    internal func registerDevice(deviceInformation: DeviceRegistration, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(DeviceService.identify(parameters: deviceInformation.toParams()),
                                    onSuccess: { (_) in
                                        onSuccess()
                                        //networkResponse.printDescription()
            },
                                    onError: { (errorResponse) in
                                        onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((errorParser?.getError(error: error))!)
        }
    }
}
