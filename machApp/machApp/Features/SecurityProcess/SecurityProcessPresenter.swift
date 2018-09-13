//
//  SecurityProcessPresenter.swift
//  machApp
//
//  Created by Lukas Burns on 4/13/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class SecurityProcessPresenter: SecurityProcessPresenterProtocol {
    
    weak var view: SecurityProcessViewProtocol?
    var repository: SecurityProcessRepositoryProtocol?
    var securityRequestType: SecurityRequestType?
    
    var delegate: SecurityProcessDelegate?
    
    required init(repository: SecurityProcessRepositoryProtocol?) {
        self.repository = repository
    }
    
    func setView(view: SecurityProcessViewProtocol) {
        self.view = view
    }
    
    func initializeProcess(_ processType: SecurityRequestType, with delegate: SecurityProcessDelegate?) {
        self.delegate = delegate
        self.securityRequestType = processType
    }

}
