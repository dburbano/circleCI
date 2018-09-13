//
//  TaxesRepository.swift
//  machApp
//
//  Created by Lukas Burns on 11/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class TaxesRepository: TaxesRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: VerifyUserErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: VerifyUserErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

}
