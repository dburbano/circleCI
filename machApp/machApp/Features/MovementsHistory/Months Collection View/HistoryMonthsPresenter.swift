//
//  HistoryMonthsPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class HistoryMonthsPresenter: HistoryMonthsPresenterProtocol {

    weak var view: HistoryMonthsViewProtocol?
    var repository: HistoryMonthsRepositoryProtocol?

    var datesArray = [MonthDate]()

    required init(repository: HistoryMonthsRepositoryProtocol?) {
        self.repository = repository
    }

    func set(view: HistoryMonthsViewProtocol) {
        self.view = view
    }

    func fetchHistoryMonths() {
        repository?.fetchHistoryMonths(onSuccess: {[weak self] response in
            self?.datesArray = response
            self?.view?.didFetchHistoryMonths()
            }, onFailure: {[weak self] in
                self?.view?.didNotFetchHistoryMonths()
        })
    }

    func elementsCount() -> Int {
        return datesArray.count
    }

    func element(at index: Int) -> MonthDate {
        return datesArray[index]
    }
}
