//
//  GeneratePrepaidCardRepository.swift
//  machApp
//
//  Created by Lukas Burns on 4/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class GeneratePrepaidCardRepository: GeneratePrepaidCardRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: GeneratePrepaidCardErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: GeneratePrepaidCardErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }
    
    internal func generatePrepaidCard( onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.requestAndDecrypt(PrepaidCardService.generatePrepaidCard(), onSuccess: { (jsonResponse) in
            onSuccess()
        }, onError: { (error) in
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(networkError: error))!)
        })
        
    }
}
