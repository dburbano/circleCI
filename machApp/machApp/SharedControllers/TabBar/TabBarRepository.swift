//
//  TabBarRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class TabBarRepository: TabBarRepositoryProtocol {
    
    var apiService: APIServiceProtocol?
    var errorParser: TabErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: TabErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func getHistory(onSuccess: @escaping (Results<Group>) -> Void, onFailure: @escaping () -> Void) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let groups = realm.objects(Group.self).sorted(byKeyPath: "updatedAt", ascending: false)
            onSuccess(groups)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }
    
    func getPrepaidCards(onSuccess: @escaping ([PrepaidCard]) -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.requestAndDecrypt(PrepaidCardService.getPrepaidCards(), onSuccess: { (jsonResponse) in
            do {
                let prepaidCardsResponse = try PrepaidCardsResponse.create(from: jsonResponse)
                let prepaidCards = prepaidCardsResponse.prepaidCards.map({ (prepaidCardResponse) -> PrepaidCard in
                    return PrepaidCard(prepaidCardResponse: prepaidCardResponse)
                })
                do {
                    let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
                    try realm.write {
                        realm.add(prepaidCards, update: true)
                    }
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                }
                onSuccess(prepaidCards)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                onFailure((self.errorParser?.getError(error: error))!)
            }
        }, onError: { (error) in
            onFailure((self.errorParser?.getError(networkError: error))!)
        })
    }
    
    func getLocalPrepaidCards(onSuccess: @escaping ([PrepaidCard]) -> Void, onFailure: () -> Void) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let prepaidCards = Array(realm.objects(PrepaidCard.self))
            onSuccess(prepaidCards)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure()
        }
    }
}
