//
//  WithdrawRemoveCashoutConfirmRepository.swift
//  machApp
//
//  Created by Rodrigo Russell on 22/3/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class WithdrawRemoveCashoutConfirmRepository: WithdrawRemoveCashoutConfirmRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: WithdrawRemoveChasoutConfirmErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: WithdrawRemoveChasoutConfirmErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    } 

    func removeCurrentCashoutATM(with cashOutAtmId: String, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            apiService?.request(CashService.deleteCashoutATM(id: cashOutAtmId), onSuccess: { _ in
                onSuccess()
            }, onError: { (errorResponse) in
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        }
    }

}
