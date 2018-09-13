//
//  HistoryTransferModel.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/11/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct HistoryTransferModel {

    var monthDate: String
    var page: String?
    var lastID: String?
    var initID: String?

    public init(date: Date) {
        self.monthDate = date.isoStringForDate()
    }

    init(date: Date, page: String, lastID: String, initID: String) {
        self.init(date: date)
        self.page = page
        self.lastID = lastID
        self.initID = initID
    }
}

extension HistoryTransferModel: WrapCustomizable {
    public func toParams() throws -> [String: Any] {
        return try Wrapper().wrap(object: self)
    }

    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "monthDate" {
            return "month_date"
        } else if propertyName == "lastID" {
            return "last_id"
        } else if propertyName == "initID" {
            return "init_id"
        } else {
            return propertyName
        }
    }
}
