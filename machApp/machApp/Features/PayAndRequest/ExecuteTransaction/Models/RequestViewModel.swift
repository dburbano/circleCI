//
//  RequestViewModel.swift
//  machApp
//
//  Created by lukas burns on 5/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class RequestViewModel: MovementViewModel {

    var userAmountViewModels: [UserAmountViewModel]
    var totalAmount: Int
    var message: String
    var balance: Int
    var metaData: TransactionMetadata?

    init(userAmountViewModels: [UserAmountViewModel], totalAmount: Int, message: String, balance: Int) {
        self.userAmountViewModels = userAmountViewModels
        self.totalAmount = totalAmount
        self.message = message
        self.balance = balance
    }

    func isPayment() -> Bool {
        return false
    }
}
