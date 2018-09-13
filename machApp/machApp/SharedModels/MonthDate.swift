//
//  MonthDate.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

struct MonthDate {

    let date: Date
    let month: String
    let year: String

    init(date: Date) {
        self.date = date
        let calendar = Calendar.current
        month = date.monthForDate()
        year = "\(calendar.component(.year, from: date))"
    }
}
