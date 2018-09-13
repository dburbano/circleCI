//
//  PrepaidCardInformationRepository.swift
//  machApp
//
//  Created by Lukas Burns on 7/31/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class PrepaidCardInformationRepository: PrepaidCardInformationRepositoryProtocol {
    
    var apiService: APIServiceProtocol?
    var errorParser: PrepaidCardInformationErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: PrepaidCardInformationErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }
    
    internal func getPrepaidCardCVVFor(prepaidCardId: String, onSuccess: @escaping (PrepaidCardCVVResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.requestAndDecrypt(PrepaidCardService.getCVV(prepaidCardId: prepaidCardId), onSuccess: { (jsonResponse) in
            do {
                let prepaidCardCVV = try PrepaidCardCVVResponse.create(from: jsonResponse)
                onSuccess(prepaidCardCVV)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                onFailure((self.errorParser?.getError(error: error))!)
            }
        }, onError: { (error) in
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(networkError: error))!)
        })
        
    }
    
    internal func getPrepaidCardPANFor(prepaidCardId: String, onSuccess: @escaping (PrepaidCardPANResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.requestAndDecrypt(PrepaidCardService.getPAN(prepaidCardId: prepaidCardId), onSuccess: { (jsonResponse) in
            do {
                let prepaidCardPAN = try PrepaidCardPANResponse.create(from: jsonResponse)
                onSuccess(prepaidCardPAN)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                onFailure((self.errorParser?.getError(error: error))!)
            }
        }, onError: { (error) in
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(networkError: error))!)
        })
    }
}
