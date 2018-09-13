//
//  WithdrawRemoveCashoutConfirmPresenter.swift
//  machApp
//
//  Created by Rodrigo Russell on 22/3/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class WithdrawRemoveCashoutConfirmPresenter: WithdrawRemoveCashoutConfirmPresenterProtocol {

    weak var view: WithdrawRemoveCashoutConfirmViewProtocol?
    var repository: WithdrawRemoveCashoutConfirmRepositoryProtocol?

    required init(repository: WithdrawRemoveCashoutConfirmRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: WithdrawRemoveCashoutConfirmViewProtocol) {
        self.view = view
    }

    func removeCurrentCashoutATM(id: String) {
        self.repository?.removeCurrentCashoutATM(with: id, onSuccess: {
//            Thread.runOnMainQueue(2) {
                self.view?.goToRemovedConfirmMessage()
//            }
        }, onFailure: { (apiError) in
            print("ERRROR! \(apiError)")
        })
    }
    
}
