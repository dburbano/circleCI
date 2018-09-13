//
//  MoreRepository.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/18/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class MoreRepository: MoreRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: MoreErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: MoreErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func isUsersMailValidated(response: (Bool) -> Void) {
        response(AccountManager.sharedInstance.getIsMailValidated())
    }
}
