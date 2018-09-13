//
//  InitialLegalContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 7/31/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

protocol TermsAndConditionsDetailsViewProtocol: BaseViewProtocol {
    func loadLegalTerms(htmlString: String)
    func navigateBack()
    func showSpinner()
    func hideSpinner()
}

protocol TermsAndConditionsDetailsPresenterProtocol: BasePresenterProtocol {
    func setView(view: TermsAndConditionsDetailsViewProtocol)
    func loadLegalTerms()
    func navigateBackTapped()
}

protocol TermsAndConditionsDetailsRepositoryProtocol {

    func getTermsAndConditions(onSuccess: @escaping (TermsAndConditionsResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum TermsAndConditionsDetailsError: Error {

}

class TermsAndConditionsDetailsErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
