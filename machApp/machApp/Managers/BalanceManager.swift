//
//  BalanceManager.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 10/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class BalanceManager {
    static let sharedInstance = BalanceManager()

    private init() {}

    //This method grants that the balance to be saved has a newer timestamp than the current saved balance.
    private func verify(date: Date) -> Bool {
        if let lastSavedBalance = getBalance() {
            return lastSavedBalance.lastRetrievedDate < date
        } else {
            //In case there's no saved balance, proceed to save one
            return true
        }
    }

    func save(balance: Balance) {
        if verify(date: balance.lastRetrievedDate) {
            do {
                let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
                try realm.write {
                    realm.add(balance, update: true)
                }
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
            }
        }
    }

    func getBalance() -> Balance? {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            return realm.objects(Balance.self).first
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            return nil
        }
    }
}
