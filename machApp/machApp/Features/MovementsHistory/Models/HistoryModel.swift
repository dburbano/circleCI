//
//  HistoryModel.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/11/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

struct HistoryModel {
    var array: [TransactionModel]
    var links: HistoryLinks
    var page: HistoryPage
    var lastID: String
    var initID: String
}

extension HistoryModel: Unboxable {

    init(unboxer: Unboxer) throws {
        array = try unboxer.unbox(key: "history")
        links = try unboxer.unbox(key: "links")
        page = try unboxer.unbox(key: "page")
        lastID = try unboxer.unbox(key: "last_id")
        initID = try unboxer.unbox(key: "init_id")
    }

    static func createOject(from dictionary: JSON) throws -> HistoryModel {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: HistoryModel = try unbox(dictionary: dictionaryObject)
        return response
    }
}

struct TransactionModel {
    var transactionDate: Date
    var transactionTitle: String
    var transactionDescription: String
    var transactionAmount: Int
    var transactionFilterType: TransactionFilterType
    var transactionOriginalType: TransactionOriginalType
//    var balance: Int

}

extension TransactionModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        transactionTitle = try unboxer.unbox(key: "type")
        transactionDescription = try unboxer.unbox(key: "name")
        transactionAmount = try unboxer.unbox(key: "amount")
        transactionDate =  try Date().dateFromISOString(isoDateString: unboxer.unbox(key: "date")) ?? Date()
        transactionFilterType = TransactionFilterType(rawValue: try unboxer.unbox(key: "filter_type")) ?? TransactionFilterType.other
        transactionOriginalType = TransactionOriginalType(rawValue: try unboxer.unbox(key: "original_type")) ?? TransactionOriginalType.other
    }
}

struct HistoryLinks {
    var current: String
    var next: String?
}

extension HistoryLinks: Unboxable {
    public init(unboxer: Unboxer) throws {
        current = try unboxer.unbox(key: "current")
        if unboxer.dictionary["next"] != nil {
            next = unboxer.unbox(key: "next")
        }
    }
}

struct HistoryPage {
    var current: String
    var next: String?
}

extension HistoryPage: Unboxable {
    public init(unboxer: Unboxer) throws {
        current = try unboxer.unbox(key: "current")
        if unboxer.dictionary["next"] != nil {
            next = unboxer.unbox(key: "next")
        }
    }
}
