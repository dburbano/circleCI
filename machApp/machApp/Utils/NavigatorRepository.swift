//
//  NavigatorRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class NavigatorRepository {
    
    let apiService = AlamofireNetworkLayer.sharedInstance
    
    func getTransaction(with movement: MovementTransferModel, onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        do {
            try apiService.request(MovementsService.getMovement(parameters: movement.toParams()), onSuccess: { networkResponse in
                do {
                    // swiftlint:disable:next force_unwrapping
                    let transaction = try Transaction.create(from: networkResponse.body!)
                    try TransactionManager.handleTransactionReceived(transaction: transaction)
                    onSuccess()
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure()
                }
            }, onError: { errorResponse in
                onFailure()
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure()
        }
    }
    
    func getTransaction(with id: String) -> TransactionViewModel? {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let predicate = NSPredicate(format: "identifier = %@ ", id)
            guard let transaction = realm.objects(Transaction.self).filter(predicate).first else { return nil }
            return TransactionViewModel(transaction: transaction)
        } catch {
            return nil
        }
    }
    
    func getGroup(with id: String) -> GroupViewModel? {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let predicate = NSPredicate(format: "identifier = %@ ", id)
            guard let group = realm.objects(Group.self).filter(predicate).first else { return nil }
            return GroupViewModel(group: group)
        } catch {
            return nil
        }
    }
    
    func getUser(with id: String) -> UserAmountViewModel? {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let predicate = NSPredicate(format: "machId = %@ ", id)
            guard let user = realm.objects(User.self).filter(predicate).first else { return nil }
            return UserAmountViewModel(user: user)
        } catch {
            return nil
        }
    }
    
    func getUser(with id: String, onSuccess: @escaping (User) -> Void, onFailure: @escaping () -> Void) {
        apiService.request(ProfileService.get(parameters: ["machId": id]), onSuccess: { networkResponse in
            do {
                // swiftlint:disable:next force_unwrapping
                let recievedUser = try User.create(from: networkResponse.body!)
                if let user = ContactManager.sharedInstance.upsertUser(receivedUser: recievedUser) {
                    onSuccess(user)
                }
                onFailure()
            } catch {
                onFailure()
            }
        }, onError: { errorResponse in
            onFailure()
        })
    }
    
    func updateUser(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        AlamofireNetworkLayer.sharedInstance.request(ProfileService.me, onSuccess: {(networkResponse) in
            do {
                let userProfileResponse = try UserProfileResponse.create(from: networkResponse.body!)
                AccountManager.sharedInstance.updateUserWithProfileResponse(userProfileResponse: userProfileResponse)
                SegmentManager.sharedInstance.identifyUser()
                onSuccess()
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
            }
        }) {(networkError) in
            onFailure()
        }
    }
    
    func getChatHistory(with groupIdentifier: String, onSuccess: @escaping ([Transaction]) -> Void, onFailure: @escaping () -> Void) {
        let chatHistoryRequest = ChatHistory(groupId: groupIdentifier,
                                             lastUpdatedAt: nil,
                                             lastId: nil)
        do {
            try AlamofireNetworkLayer.sharedInstance
                .request(AccountService.chatHistory(params: chatHistoryRequest.toParams()),
                         onSuccess: { (networkResponse) in
                            do {
                                let transactions: [Transaction] = try Transaction.createArray(from: networkResponse.body!)
                                onSuccess(transactions)
                            } catch {
                                ExceptionManager.sharedInstance.recordError(error)
                                onFailure()
                            }}, onError: { (responseError) in
                                onFailure()})
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure()
        }
    }
}
