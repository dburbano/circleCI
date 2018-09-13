//
//  InitialLegalPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 7/31/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class TermsAndConditionsDetailsPresenter: TermsAndConditionsDetailsPresenterProtocol {

    var view: TermsAndConditionsDetailsViewProtocol?
    var repository: TermsAndConditionsDetailsRepositoryProtocol?

    required init(repository: TermsAndConditionsDetailsRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: TermsAndConditionsDetailsViewProtocol) {
        self.view = view
    }

    func loadLegalTerms() {
        self.view?.showSpinner()
        self.repository?.getTermsAndConditions(onSuccess: { (termsAndConditionsResponse) in
            if let termsAndConditionsHtml = termsAndConditionsResponse.termsAndConditions {
                self.view?.loadLegalTerms(htmlString: termsAndConditionsHtml)
            }
            self.view?.hideSpinner()
        }, onFailure: { (error) in
            self.handle(error: error)
            self.view?.hideSpinner()
        })
    }

    func navigateBackTapped() {
        view?.navigateBack()
    }



    private func handle(error apiError: ApiError) {
        switch apiError {
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let initialLegalError):
            guard initialLegalError is TermsAndConditionsDetailsError else { return }
            break
        case .clientError(let initialLegalError):
            guard initialLegalError is TermsAndConditionsDetailsError else { return }
            break
        default:
            self.view?.showServerError()
        }
    }
}
