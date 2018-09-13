//
//  HistoryMonthsContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol HistoryMonthsViewProtocol: BaseViewProtocol {
    func didFetchHistoryMonths()
    func didNotFetchHistoryMonths()
}

protocol HistoryMonthsPresenterProtocol: BasePresenterProtocol {
    func set(view: HistoryMonthsViewProtocol)
    func fetchHistoryMonths()
    func elementsCount() -> Int
    func element(at index: Int) -> MonthDate
}

protocol HistoryMonthsRepositoryProtocol {
    func fetchHistoryMonths(onSuccess: ([MonthDate]) -> Void, onFailure: () -> Void)
}
