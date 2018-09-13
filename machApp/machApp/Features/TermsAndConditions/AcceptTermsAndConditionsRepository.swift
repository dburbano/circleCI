//
//  AcceptTermsAndConditionsDetailsRepository.swift
//  
//
//  Created by Lukas Burns on 11/17/17.
//

import Foundation

class AcceptTermsAndConditionsRepository: AcceptTermsAndConditionsRepositoryProtocol {
    
    var apiService: APIServiceProtocol?
    var errorParser: AcceptTermsAndConditionsErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: AcceptTermsAndConditionsErrorParser?) {
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
