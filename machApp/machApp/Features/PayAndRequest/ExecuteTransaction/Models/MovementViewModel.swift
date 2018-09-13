//
//  MovementViewModel.swift
//  machApp
//
//  Created by lukas burns on 5/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol MovementViewModel {

    var userAmountViewModels: [UserAmountViewModel] { get set }
    var totalAmount: Int { get set }
    var message: String { get set }
    var balance: Int { get set }
    var metaData: TransactionMetadata? { get set }

    func isPayment() -> Bool
}
