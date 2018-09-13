//
//  PrepaidCardInformationContract.swift
//  machApp
//
//  Created by Lukas Burns on 7/31/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

/*
 Contract File
*/

import Foundation

protocol PrepaidCardInformationDelegate {
    func prepaidCardInformationShown()
    func prepaidCardInformationHidden()
    func prepaidCardDetailRequested(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void)
}

protocol PrepaidCardInformationViewProtocol: BaseViewProtocol {
    func setCardHolderName(name: String)
    func setExpirationDate(date: String)
    func setPAN(digits: String)
    func setCVV(digits: String)
    func setSeeCardDetailButtonText(text: String)
    func setSeeCardDetailButtonAsLoading()
    func setHideIconToCardDetailButton()
    func setShowIconToCardDetailButton()
    func presentPasscode(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void, with text: String)
}

protocol PrepaidCardInformationPresenterProtocol: BasePresenterProtocol {
    func set(view: PrepaidCardInformationViewProtocol)
    func setup(prepaidCard: PrepaidCard?)
    func setDelegate(delegate: PrepaidCardInformationDelegate?)
    func showOrHidePrepaidCardInformation()
}

protocol PrepaidCardInformationRepositoryProtocol {
    func getPrepaidCardCVVFor(prepaidCardId: String, onSuccess: @escaping (PrepaidCardCVVResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getPrepaidCardPANFor(prepaidCardId: String, onSuccess: @escaping (PrepaidCardPANResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum PrepaidCardInformationError: Error {
    
}

class PrepaidCardInformationErrorParser: ErrorParser {
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
