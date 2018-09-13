//
//  RecoverAccountRepository.swift
//  machApp
//
//  Created by Lukas Burns on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class RecoverAccountRepository: RecoverAccountRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: RecoverAccountErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: RecoverAccountErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }
    
    func validateRUTExists(rut: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
         apiService?.request(AuthenticationService.recoverAccount(parameters: ["rut": rut]), onSuccess: { response in
            do {
                //swiftlint:disable:next force_unwrapping
                let authenticationResponse = try AuthenticationResponse.create(from: response.body!)
                onSuccess(authenticationResponse)
            } catch {
                onFailure((self.errorParser?.getError(error: error))!)
            }
        }, onError: {[weak self] networkError in
            //swiftlint:disable:next force_unwrapping
            onFailure((self?.errorParser?.getError(networkError: networkError))!)
        })
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
