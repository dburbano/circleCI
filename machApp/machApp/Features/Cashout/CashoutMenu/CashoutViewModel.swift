//
//  CashoutViewModel.swift
//  machApp
//
//  Created by lukas burns on 6/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class CashoutViewModel {

    var bank: Bank
    var amount: Int
    var accountNumber: String

    var userViewModel: UserViewModel

    init(userViewModel: UserViewModel, amount: Int, accountNumber: String, bank: Bank) {
        self.userViewModel = userViewModel
        self.amount = amount
        self.accountNumber = accountNumber
        self.bank = bank
    }
}
