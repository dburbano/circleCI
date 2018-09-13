//
//  SecurityProcessRepository.swift
//  machApp
//
//  Created by Lukas Burns on 4/13/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class SecurityProcessRepository: SecurityProcessRepositoryProtocol {
    
    var apiService: APIServiceProtocol?
    var errorParser: SecurityProcessErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: SecurityProcessErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

}
