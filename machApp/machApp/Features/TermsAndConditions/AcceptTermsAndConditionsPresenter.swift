//
//  AcceptTermsAndConditionsPresenter.swift
//  machApp
//
//  Created by Lukas Burns on 11/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class AcceptTermsAndConditionsPresenter: AcceptTermsAndConditionsPresenterProtocol {

    weak var view: AcceptTermsAndConditionsViewProtocol?
    var repository: AcceptTermsAndConditionsRepositoryProtocol?

    var termsAndConditionsProcess: TermsAndConditionsProcess? {
        didSet {
            if let process = termsAndConditionsProcess {
                switch process {
                case .generateCard:
                    self.view?.hideTaxesOption()
                case .register:
                    break
                }
            }
        }
    }
    var selectedTaxableCountries: [TaxableCountry] = []

    required init(repository: AcceptTermsAndConditionsRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: AcceptTermsAndConditionsViewProtocol) {
        self.view = view
    }

    func termsAndConditionsAccepted() {
        self.view?.disableRegisterButton()
        let chileanTax = TaxableCountry(country: "Chile", dni: "", countryCode: "CL")
        var termsAndConditionsAcceptance = TermsAndConditionsAcceptance(taxes: [chileanTax])
        if !selectedTaxableCountries.isEmpty {
            termsAndConditionsAcceptance = TermsAndConditionsAcceptance(taxes: selectedTaxableCountries)
        }
        self.repository?.acceptTermsAndConditions(termsAndConditionsAcceptance: termsAndConditionsAcceptance, onSuccess: {
            SegmentAnalytics.Event.termsAccepted.track()
            self.handleTermsAndConditionSuccess()
        }, onFailure: { (error) in
            self.view?.enableRegisterButton()
            self.handle(error: error, showDefaultError: true)
        })
    }
    
    private func handleTermsAndConditionSuccess() {
        if let termsAndConditionsRequired = self.termsAndConditionsProcess {
            switch termsAndConditionsRequired {
            case .generateCard:
                self.view?.navigateBackWithSuccess()
            case .register:
                self.view?.navigateToRegisterUser()
            }
        }
    }

    func setSelectedTaxes(selectedTaxableCountries: [TaxableCountry]) {
        self.selectedTaxableCountries = selectedTaxableCountries
    }

    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let initialLegalError):
            guard initialLegalError is TermsAndConditionsDetailsError else { return }
            break
        case .clientError(let initialLegalError):
            guard initialLegalError is TermsAndConditionsDetailsError else { return }
            break
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }

}
