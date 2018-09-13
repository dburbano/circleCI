//
//  SecurityProcessContract.swift
//  machApp
//
//  Created by Lukas Burns on 4/13/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol SecurityProcessViewProtocol: BaseViewProtocol {
    
}

protocol SecurityProcessPresenterProtocol: BasePresenterProtocol {
    func setView(view: SecurityProcessViewProtocol)
    func initializeProcess(_ processType: SecurityRequestType, with delegate: SecurityProcessDelegate?)
}

protocol SecurityProcessRepositoryProtocol {

}

enum SecurityProcessError: Error {

}

class SecurityProcessErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
