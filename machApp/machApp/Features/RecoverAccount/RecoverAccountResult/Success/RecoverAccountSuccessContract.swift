//
//  RecoverAccountSuccessContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 7/11/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation


protocol RecoverAccountSuccesssViewProtocol: class {
    func set(userFirstName: String)
}

protocol RecoverAccountSuccesssPresenterProtocol: BasePresenterProtocol {
    var view: RecoverAccountSuccesssViewProtocol? { get set }
    func getUserFirstName()
}
