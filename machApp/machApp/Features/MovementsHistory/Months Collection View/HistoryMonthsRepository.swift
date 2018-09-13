//
//  HistoryMonthsRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class HistoryMonthsRepository: HistoryMonthsRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: ErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: ErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func fetchHistoryMonths(onSuccess: ([MonthDate]) -> Void, onFailure: () -> Void) {
        //User's sign up date

        //If there is no saved date, call onFailure()
        guard let signUpDate = AccountManager.sharedInstance.getDate()?.startOfMonth()
            else {
                return onFailure()
        }

        //Current date
        var currentDate = Date()

        // Dates Array
        var datesArray: [MonthDate] = [MonthDate]()

        // The basic idea behind this loop is to iterate from the current date until the first day of the signUpDate's month
        while currentDate > signUpDate {
            //Round signup date to begging of month
            let roundedDate = currentDate.startOfMonth()
            let monthDate = MonthDate(date: roundedDate)
            datesArray.append(monthDate)
            currentDate = currentDate.addMonths(number: -1)
        }
        onSuccess(datesArray)
    }
}
