//
//  RecoverAccountSuccessPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 7/11/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class RecoverAccountSuccesssPresenter: RecoverAccountSuccesssPresenterProtocol {
    
    weak var view: RecoverAccountSuccesssViewProtocol?
    
    func getUserFirstName() {
        view?.set(userFirstName: AccountManager.sharedInstance.getUserFirstName())
    }
}
