//
//  GeneratePrepaidCardContract.swift
//  machApp
//
//  Created by Lukas Burns on 4/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol GeneratePrepaidCardViewProtocol: BaseViewProtocol {

    func setGenerateButtonAsLoading()
    func setGenerateButtonAsActive()
    func setGenerateButtonAsDisabled()
    func setCheckboxAsSelected()
    func setCheckboxAsUnselected()
    func navigateToGeneratingPrepaidCard()
    func navigateToPrepaidCard(with card: PrepaidCard)
}

protocol GeneratePrepaidCardPresenterProtocol: BasePresenterProtocol {

    var isTermsAndConditionsAccepted: Bool { get set }
    func setView(view: GeneratePrepaidCardViewProtocol)
    func generateCard()
    func seeTermsAndConditions()
    func termsAndConditionsCheckboxPressed()
}

protocol GeneratePrepaidCardRepositoryProtocol {
    func generatePrepaidCard( onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum GeneratePrepaidCardError: Error {
    
}

class GeneratePrepaidCardErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
