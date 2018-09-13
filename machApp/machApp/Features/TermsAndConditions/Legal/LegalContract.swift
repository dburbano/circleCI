//
//  LegalContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 7/31/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

protocol LegalViewProtocol: BaseViewProtocol {
    func navigateBack()
}

protocol LegalPresenterProtocol: BasePresenterProtocol {
    func setView(view: LegalViewProtocol)
    func navigateBackTapped()
}

protocol LegalRepositoryProtocol {
    //Service
}

enum LegalError: Error {
    
}

class LegalErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
