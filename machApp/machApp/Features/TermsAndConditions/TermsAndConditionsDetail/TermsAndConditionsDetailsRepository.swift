//
//  InitialLegalRepository.swift
//  machApp
//
//  Created by lukas burns on 8/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class TermsAndConditionsDetailsRepository: TermsAndConditionsDetailsRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: TermsAndConditionsDetailsErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: TermsAndConditionsDetailsErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }
    
    func getTermsAndConditions(onSuccess: @escaping (TermsAndConditionsResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.request(TermsAndConditionsService.get, onSuccess: { (networkResponse) in
            do {
                //swiftlint:disable:next force_unwrapping
                let termsAndConditions = try TermsAndConditionsResponse.create(from: networkResponse.body!)
                onSuccess(termsAndConditions)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                 onFailure((self.errorParser?.getError(error: error))!)
            }
        },
            onError: { (errorResponse) in
            onFailure((self.errorParser?.getError(networkError: errorResponse))!)
        })
    }

}
