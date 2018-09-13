//
//  TransactionsHistoryRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import SwiftyJSON

class TransactionsHistoryRepository: TransactionsHistoryRepositoryProtocol {
    
    var apiService: APIServiceProtocol?
    var errorParser: ErrorParser?
    var operationQueue = OperationQueue()
    
    required init(apiService: APIServiceProtocol?, errorParser: ErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
        
        operationQueue.maxConcurrentOperationCount = 1
    }
    
    func fetchTransactions(with date: Date, onSuccess: @escaping (HistoryModel) -> Void, onFailure: @escaping () -> Void) {
        do {
            let operation = try NetworkOperation(apiService: apiService, service: MovementsService.getHistory(parameters: HistoryTransferModel(date: date).toParams()), onSuccess: { response in
                    do {
                        //swiftlint:disable:next force_unwrapping
                        let historyResponse = try HistoryModel.createOject(from: response.body!)
                        onSuccess(historyResponse)
                    } catch {
                        ExceptionManager.sharedInstance.recordError(error)
                        onFailure()
                    }
            }, onError: { errorResponse in
                onFailure()
            })
            operationQueue.addOperation(operation)
        } catch {
                onFailure()
        }
    }
    
    //swiftlint:disable:next function_parameter_count
    func fetchTransactionsPaginated(with date: Date, page: String, lastID: String, initID: String, onSuccess: @escaping (HistoryModel) -> Void, onFailure: @escaping () -> Void) {
        //The purpose of this conditional is to ensure we only have one donwload operation
        if operationQueue.operationCount == 0 {
            do {
                let operation = try NetworkOperation(apiService: apiService, service: MovementsService.getHistory(parameters: HistoryTransferModel(date: date, page: page, lastID: lastID, initID: initID).toParams()), onSuccess: {response in
                    do {
                        //swiftlint:disable:next force_unwrapping
                        let historyResponse = try HistoryModel.createOject(from: response.body!)
                        onSuccess(historyResponse)
                    } catch {
                        ExceptionManager.sharedInstance.recordError(error)
                        onFailure()
                    }
                }, onError: {errorResponse in
                    onFailure()
                })
                operationQueue.addOperation(operation)
        } catch {
            onFailure()
        }

        }
    }
    
    func cancelOperations() {
        //This piece of code is to ensure that when the user changes the month filter, we stop the background operations, in case they are executing
        if operationQueue.operationCount > 0 {
            operationQueue.cancelAllOperations()
        }
    }
}

/*
 This piece of code is in case we need to test against a mocked response
 if let data = json.data(using: .utf8) {
 if let asdf = try? JSON(data: data) {
 print(asdf)
 let array = try HistoryModelArray.createOject(from: asdf)
 print(array)
 }
 }
 
let json = """
{ \"history\":
[
{ \"amount\": 5, \"date\": "2018-01-06T17:44:42.436Z", \"name\": "Pedro Perez",\"type\": "Recarga" },
{ \"amount\": 5, \"date\": "2018-01-06T17:44:42.436Z", \"name\": "Pedro Perez",\"type\": "Recarga" },
{ \"amount\": 5, \"date\": "2018-01-06T17:44:42.436Z", \"name\": "Pedro Perez",\"type\": "Recarga" },
{ \"amount\": 5, \"date\": "2018-01-06T17:44:42.436Z", \"name\": "Pedro Perez",\"type\": "Recarga" }
],
\"links\": {
\"current\": "/mobile/movements/history?last_id=50&month_date=2018-01-23T20:06:57.318Z&next_page=2",
\"next\": null
},
\"last_id\":2,
\"page\": {
\"current\": 2,
\"next\": null
},
}
"""
 */
