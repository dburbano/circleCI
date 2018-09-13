//
//  RegisterDeviceRepository.swift
//  machApp
//
//  Created by lukas burns on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class RegisterDeviceRepository: RegisterDeviceRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: RegisterDeviceErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: RegisterDeviceErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
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
    
    internal func acceptTermsAndConditions(termsAndConditionsAcceptance: TermsAndConditionsAcceptance, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(TermsAndConditionsService.accept(parameters: termsAndConditionsAcceptance.toParams()), onSuccess: { (_) in
                onSuccess()
            }, onError: { (errorResponse) in
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((errorParser?.getError(error: error))!)
        }
    }
}

