//
//  IdentityRecoveryResultRepository.swift
//  machApp
//
//  Created by lukas burns on 5/18/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class IdentityRecoveryResultRepository: IdentityRecoveryResultRepositoryProtocol {
    var apiService: APIServiceProtocol?

    required init(apiService: APIServiceProtocol?) {
        self.apiService = apiService
    }
}
