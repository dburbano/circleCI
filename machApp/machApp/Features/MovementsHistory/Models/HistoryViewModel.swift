//
//  HistoryModel.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

enum TransactionOriginalType: String {
    case annuled = "prepaid-card-annulled-charge"
    case other = ""
}

enum TransactionFilterType: String {
    case paymentSent = "payment-sent"
    case paymentReceived = "payment-received"
    case cashIn = "cash-in"
    case cashout = "cash-out"
    case machCard = "mach-card"
    case other = ""
}

class HistoryViewModel {

    var date: String
    var transactionFilterType: TransactionFilterType
    var transactionOriginalType: TransactionOriginalType
    var amount: Int
//    var balance: String
    var description: String
    var title: String

    init(with transactionModel: TransactionModel) {
        self.date = transactionModel.transactionDate.getDayMonthDate()
        self.transactionFilterType = transactionModel.transactionFilterType
        self.transactionOriginalType = transactionModel.transactionOriginalType
        self.description = transactionModel.transactionDescription
        self.title = transactionModel.transactionTitle
        self.amount = transactionModel.transactionAmount
//        balance = historyModel.balance.toCurrency()
    }
}
