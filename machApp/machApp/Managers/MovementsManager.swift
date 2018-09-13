//
//  TransactionsManager.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/4/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class MovementsManager {

    static let sharedInstance = MovementsManager()

    private init() {}

    func getTransaction(with id: String) -> TransactionViewModel? {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let predicate = NSPredicate(format: "identifier = %@ ", id)
            guard let transaction = realm.objects(Transaction.self).filter(predicate).first else { return nil }
            return TransactionViewModel(transaction: transaction)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            return nil
        }
    }
}
