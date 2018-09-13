//
//  ValidatePhoneNumberRepository.swift
//  machApp
//
//  Created by lukas burns on 3/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class ValidatePhoneNumberRepository: ValidatePhoneNumberRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: ValidatePhoneNumberErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: ValidatePhoneNumberErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    //MARK: Send SMS
    
    //This web request is used when accountMode is create
    func validatePhoneNumber(phoneNumberValidation: PhoneNumberValidation, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(PhoneVerificationService.verify(parameters: phoneNumberValidation.toParams()),
                onSuccess: { (_) in
                    onSuccess()
            }, onError: { (responseError) in
                //swiftlint:disable:next force_unwrapping
                onFailure((self.errorParser?.getError(networkError: responseError))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
    
    //This web request is used when accountMode is recovery
    func validatePhoneNumber(phoneNumberValidation: PhoneNumberValidation, processId: String, onSuccess: @escaping (AuthenticationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(AuthenticationService.checkSMSCode(parameters: phoneNumberValidation.toParams(), processId: processId), onSuccess: { networkResponse in
                do {
                    // swiftlint:disable:next force_unwrapping
                    let response = try AuthenticationResponse.create(from: networkResponse.body!)
                    onSuccess(response)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { responseError in
                //swiftlint:disable:next force_unwrapping
                onFailure((self.errorParser?.getError(networkError: responseError))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
    
    //MARK: Re-send phone call

    //This web request is used when accountMode is create
    func resendPhoneNumber(phoneNumberResendInfo: PhoneNumberResend, onSuccess: @escaping (PhoneNumberRegistrationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(PhoneVerificationService.resend(parameters: phoneNumberResendInfo.toParams()),
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
    

    
    //This web request is used when accountMode is recovery
    func resendPhoneNumber(with phoneNumberResendInfo: PhoneNumberResend, processId: String, onSuccess: @escaping (PhoneNumberRegistrationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(AuthenticationService.repeatPhoneVerificationCall(parameters: phoneNumberResendInfo.toParams(), processId: processId), onSuccess: { networkResponse in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let phoneNumberRegistrationResponse = try PhoneNumberRegistrationResponse.create(from: networkResponse.body!)
                    onSuccess(phoneNumberRegistrationResponse)
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

    func resendPhoneNumberWhenExpired(phoneNumberInformation: PhoneNumberRegistration, onSuccess: @escaping (PhoneNumberRegistrationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
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
    
    //MARK: Request Phone call

    //This web-request is used when accountMode is create
    func callPhoneVerification(verificationID: String, onSuccess: @escaping (PhoneNumberRegistrationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        let dict: [String: String] = [
            "verification_id": verificationID
        ]
        do {
            apiService?.request(PhoneVerificationService.call(parameters: dict), onSuccess: { (networkResponse) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let phoneNumberRegistrationResponse = try PhoneNumberRegistrationResponse.create(from: networkResponse.body!)
                    onSuccess(phoneNumberRegistrationResponse)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: {[weak self] (responseError) in
                onFailure((self?.errorParser?.getError(networkError: responseError))!)
            })
        }
    }
    
    //This web-request is used when accountMode is recover
    func callPhoneVerification(with phoneCallTransferModel: RequestPhoneCallTransferModel, processId: String, onSuccess: @escaping (PhoneNumberRegistrationResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(AuthenticationService.requestPhoneVerificationCall(parameters: phoneCallTransferModel.toParams(), processId: processId), onSuccess: { networkResponse in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let phoneNumberRegistrationResponse = try PhoneNumberRegistrationResponse.create(from: networkResponse.body!)
                    onSuccess(phoneNumberRegistrationResponse)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: {[weak self] responseError in
                //swiftlint:disable:next force_unwrapping
                onFailure((self?.errorParser?.getError(networkError: responseError))!)})
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            //swaiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
}
