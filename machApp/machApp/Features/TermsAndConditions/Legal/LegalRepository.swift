//
//  LegalRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 7/31/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class LegalRepository: LegalRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: LegalErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: LegalErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }
}
