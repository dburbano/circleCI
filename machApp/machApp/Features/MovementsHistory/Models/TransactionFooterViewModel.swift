//
//  TransactionFooterViewModel.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 3/8/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

enum FooterState {
    case moreTransactionsAvailable
    case noMoreTransactionsAvailable
}

class TransactionFooterViewModel {
    
    let stDate: String
    let state: FooterState
    
    init(date: Date, state: FooterState) {
        stDate = date.getMonthDate()
        self.state = state
    }
}
