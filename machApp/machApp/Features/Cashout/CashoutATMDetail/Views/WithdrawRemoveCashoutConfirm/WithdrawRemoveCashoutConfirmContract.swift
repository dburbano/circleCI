//
//  WithdrawRemoveCashoutConfirmContract.swift
//  machApp
//
//  Created by Rodrigo Russell on 22/3/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol WithdrawRemoveCashoutConfirmViewProtocol: BaseViewProtocol {
    func goToRemovedConfirmMessage()
}

protocol WithdrawRemoveCashoutConfirmPresenterProtocol: BasePresenterProtocol {
    func setView(view: WithdrawRemoveCashoutConfirmViewProtocol)
    func removeCurrentCashoutATM(id: String)
}

protocol WithdrawRemoveCashoutConfirmRepositoryProtocol {
    func removeCurrentCashoutATM(with cashOutAtmId: String, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
}

class WithdrawRemoveChasoutConfirmErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }

}
