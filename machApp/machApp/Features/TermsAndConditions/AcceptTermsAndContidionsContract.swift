//
//  AcceptTermsAndContidionsContract.swift
//  machApp
//
//  Created by Lukas Burns on 11/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol AcceptTermsAndConditionsViewProtocol: BaseViewProtocol {
    func navigateBackWithSuccess()
    func navigateToRegisterUser()
    func disableRegisterButton()
    func enableRegisterButton()
    func hideTaxesOption()
}

protocol AcceptTermsAndConditionsPresenterProtocol: BasePresenterProtocol {
    var termsAndConditionsProcess: TermsAndConditionsProcess? { get set }
    func setView(view: AcceptTermsAndConditionsViewProtocol)
    func termsAndConditionsAccepted()
    func setSelectedTaxes(selectedTaxableCountries: [TaxableCountry])
}

protocol AcceptTermsAndConditionsRepositoryProtocol {
    func registerDevice(deviceInformation: DeviceRegistration, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
    func acceptTermsAndConditions(termsAndConditionsAcceptance: TermsAndConditionsAcceptance, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum AcceptTermsAndConditionsError: Error {
    
}

class AcceptTermsAndConditionsErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
