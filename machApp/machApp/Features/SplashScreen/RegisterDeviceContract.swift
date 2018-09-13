//
//  RegisterDeviceContract.swift
//  machApp
//
//  Created by lukas burns on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol RegisterDeviceViewProtocol: BaseViewProtocol {
    func navigateToVerifyIdentity()
    func navigateToRegisterUser()
    func navigateToTermsAndConditions()
    func enableRegisterButton()
    func disableRegisterButton()
    func setRegisterButtonAsLoading()
    func enableRecoverButton()
    func disableRecoverButton()
    func setCheckboxAsSelected()
    func setCheckboxAsUnselected()
    func hideTermsAndConditionsTooltip()
    func showTermsAndConditionsTooltip()
}

protocol RegisterDevicePresenterProtocol: BasePresenterProtocol {
    func recoverAccount()
    func setView(view: RegisterDeviceViewProtocol)
    func registerAccount()
    func seeTermsAndConditions()
    func termsAndConditionsCheckboxPressed()
    func hasUserAcceptedTermsAndConditions() -> Bool
}

protocol RegisterDeviceRepositoryProtocol {
    func registerDevice(deviceInformation: DeviceRegistration, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
    func acceptTermsAndConditions(termsAndConditionsAcceptance: TermsAndConditionsAcceptance, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum RegisterDeviceError: Error {
    case registerDeviceFailed(message: String)
}

class RegisterDeviceErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.statusCode == -1 {
            return ApiError.serverError(error: RegisterDeviceError.registerDeviceFailed(message: "Failed"))
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
