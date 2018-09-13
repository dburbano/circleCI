//
//  HomeRepository.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON //This has to be erased

class HomeRepository: HomeRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: HomeErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: HomeErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }
    
    internal func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            self.apiService?.request(AccountService.balance(), onSuccess: {[weak self] (networkResponse) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let balanceResponse = try BalanceResponse.create(from: networkResponse.body!)
                    BalanceManager.sharedInstance.save(balance: Balance(balanceResponse: balanceResponse))
                    onSuccess(balanceResponse)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    //swiftlint:disable:next force_unwrapping
                    onFailure((self?.errorParser?.getError(error: error))!)
                }
                }, onError: {[weak self] (responseError) in
                    //swiftlint:disable:next force_unwrapping
                    onFailure((self?.errorParser?.getError(networkError: responseError))!)
            })
        }
    }
    
    internal func getHistory(onSuccess: @escaping (Results<Group>) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let groups = realm.objects(Group.self).sorted(byKeyPath: "updatedAt", ascending: false)
            onSuccess(groups)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }
    
    internal func getGroupsAfter(lastGroup: Group?, onSuccess: @escaping ([Transaction]) -> Void, onFailure: @escaping (ApiError) -> Void) {
        let groupHistoryRequest = GroupHistory(lastGroupId: lastGroup?.identifier ?? "")
        do {
            try apiService?.request(AccountService.groupHistory(params: groupHistoryRequest.toParams()),
                                    onSuccess: { (networkResponse) in
                                        do {
                                            //swiftlint:disable:next force_unwrapping
                                            let transactions = try Transaction.createArray(from: networkResponse.body!)
                                            onSuccess(transactions)
                                        } catch {
                                            ExceptionManager.sharedInstance.recordError(error)
                                            //swiftlint:disable:next force_unwrapping
                                            onFailure((self.errorParser?.getError(error: error))!)
                                        }
            }, onError: { (responseError) in
                //swiftlint:disable:next force_unwrapping
                onFailure((self.errorParser?.getError(networkError: responseError))!)
            })
            
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
    
    internal func getSavedBalance(response: (Balance?) -> Void) {
        response(BalanceManager.sharedInstance.getBalance())
    }
    
    internal func getMachTeamProfile(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        apiService?.request(ConfigurationService.getConfiguration, onSuccess: { (networkResponse) in
            do {
                //swiftlint:disable:next force_unwrapping
                let response = try ConfigurationResponse.create(from: networkResponse.body!)
                ConfigurationManager.sharedInstance.save(machTeamConfiguration: MachTeamConfiguration(configurationResponse: response))
                ContactManager.sharedInstance.saveUsers(users: [User(with: response)])
                onSuccess()
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                onFailure()
            }
        }, onError: { _ in
            onFailure()
        })
    }
    
    internal func fetchSignupDate() {
        apiService?.request(SignupDateService.getDate(), onSuccess: { response in
            do {
                //swiftlint:disable:next force_unwrapping
                let response = try SignupDateResponse.create(from: response.body!)
                AccountManager.sharedInstance.set(date: response.signupDate)
                print(response.signupDate)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
            }
        }, onError: { _ in })
    }
    
    func updateTransactions(_ transactions: [Transaction]) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                realm.add(transactions, update: true)
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }
    
    // Get cards locally if they exist, if not get from service and save them locally
    internal func getPrepaidCards(onSuccess: @escaping ([PrepaidCard]) -> Void, onFailure: @escaping (ApiError) -> Void) {
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
    
    internal func getOwnProfile(onSuccess: @escaping (UserProfileResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.request(ProfileService.me, onSuccess: { (networkResponse) in
            do {
                //swiftlint:disable:next force_unwrapping
                let userProfileResponse = try UserProfileResponse.create(from: networkResponse.body!)
                onSuccess(userProfileResponse)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                //swiftlint:disable:next force_unwrapping
                onFailure((self.errorParser?.getError(error: error))!)
            }
        }, onError: { (errorResponse) in
            onFailure((self.errorParser?.getError(networkError: errorResponse))!)
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
    
    func isUsersMailValidated() -> Bool {
        return AccountManager.sharedInstance.getIsMailValidated()
    }
    
}
