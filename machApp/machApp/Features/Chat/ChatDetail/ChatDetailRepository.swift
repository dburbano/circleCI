//
//  ChatDetailRepository.swift
//  machApp
//
//  Created by lukas burns on 4/7/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class ChatDetailRepository: ChatDetailRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: ChatDetailErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: ChatDetailErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func updateTransactions(_ transactions: List<Transaction>) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                realm.add(transactions, update: true)
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
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

    func getTransactionsSortedByDate(groupIdentifier: String, onSuccess: @escaping (Results<Transaction>) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let transactions = realm.objects(Transaction.self).filter("groupId = %@", groupIdentifier).sorted(byKeyPath: "updatedAt", ascending: true)
            onSuccess(transactions)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
    
    func getMachMessagesSortedByDate(groupIdentifier: String, onSuccess: @escaping (Results<MachMessage>) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let transactions = realm.objects(MachMessage.self).filter("groupId = %@", groupIdentifier).sorted(byKeyPath: "createdAt", ascending: true)
            onSuccess(transactions)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    // TUDO en 1 año mas, "despues lo refactorizo".
    func acceptTransaction(transaction: Transaction, onSuccess: @escaping (Transaction) -> Void, onFailure: @escaping (ApiError) -> Void) {
        guard let transactionId = transaction.identifier else { return }
        let requestUpdate = RequestUpdate(transactionId: transactionId)
        do {
            try apiService?.request(RequestService.accept(parameters: requestUpdate.toParams()),
                onSuccess: { (networkResponse) in
                    do {
                        //swiftlint:disable:next force_unwrapping
                        let acceptResponse = try AcceptRequestResponse.create(from: networkResponse.body!)
                        do {
                            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
                            try realm.write {
                                transaction.completedAt = acceptResponse.completedAt
                                transaction.setUpdatedAt()
                            }
                            onSuccess(transaction)
                        } catch {
                            ExceptionManager.sharedInstance.recordError(error)
                            onFailure((self.errorParser?.getError(error: error))!)
                        }
                    } catch {
                        ExceptionManager.sharedInstance.recordError(error)
                        onFailure((self.errorParser?.getError(error: error))!)
                    }
            }, onError: { (responseError) in
                // errorResponse.printDescription()
                onFailure((self.errorParser?.getError(networkError: responseError))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    func rejectTransaction(transaction: Transaction, interaction: Interaction, onSuccess: @escaping (Transaction) -> Void, onFailure: @escaping (ApiError) -> Void) {
        guard let transactionId = transaction.identifier, let interactionId = interaction.id else { return }
        let interactionTransferModel = InteractionTransferModel(transactionId: transactionId, interactionId: interactionId)
        do {
            try apiService?.request(RequestService.reject(parameters: interactionTransferModel.toParams()),
                onSuccess: { (networkResponse) in
                    do {
                        //swiftlint:disable:next force_unwrapping
                        let rejectResponse = try RejectRequestResponse.create(from: networkResponse.body!)
                        let transactionInteraction = TransactionInteraction(interaction: interaction, date: rejectResponse.rejectedAt , reactedBy: AccountManager.sharedInstance.getMachId(), availableAt: nil, triesRemaining: nil)
                        do {
                            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
                            try realm.write {
                                transaction.addTransactionInteraction(transactionInteraction: transactionInteraction)
                                transaction.rejectedAt = rejectResponse.rejectedAt
                                transaction.setUpdatedAt()
                            }
                            onSuccess(transaction)
                        } catch {
                            ExceptionManager.sharedInstance.recordError(error)
                            onFailure((self.errorParser?.getError(error: error))!)
                        }
                    } catch {
                        ExceptionManager.sharedInstance.recordError(error)
                        onFailure((self.errorParser?.getError(error: error))!)
                    }
            }, onError: { (responseError) in
                // errorResponse.printDescription()
                onFailure((self.errorParser?.getError(networkError: responseError))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    func cancelTransaction(transaction: Transaction, onSuccess: @escaping (Transaction) -> Void, onFailure: @escaping (ApiError) -> Void) {
        guard let transactionId = transaction.identifier else { return }
        let requestUpdate = RequestUpdate(transactionId: transactionId)
        do {
            try apiService?.request(RequestService.cancel(parameters: requestUpdate.toParams()),
                onSuccess: { (networkResponse) in
                    do {
                        //swiftlint:disable:next force_unwrapping
                        let cancelResponse = try CancelRequestResponse.create(from: networkResponse.body!)
                        do {
                            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
                            try realm.write {
                                transaction.cancelledAt = cancelResponse.cancelledAt
                                transaction.setUpdatedAt()
                            }
                            onSuccess(transaction)
                        } catch {
                            ExceptionManager.sharedInstance.recordError(error)
                            onFailure((self.errorParser?.getError(error: error))!)
                        }
                    } catch {
                        ExceptionManager.sharedInstance.recordError(error)
                        onFailure((self.errorParser?.getError(error: error))!)
                    }
            }, onError: { (responseError) in
                // errorResponse.printDescription()
                onFailure((self.errorParser?.getError(networkError: responseError))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    func getChatHistory(before transaction: Transaction?, onSuccess: @escaping ([Transaction]) -> Void, onFailure: @escaping (ApiError) -> Void) {
        guard let lastTransactionDate = transaction?.updatedAt as Date?, let groupId = transaction?.groupId, let identifier = transaction?.identifier else { return }
        let chatHistoryRequest = ChatHistory(groupId: groupId, lastUpdatedAt: lastTransactionDate.isoStringForDate(), lastId: identifier)
        do {
            try apiService?.request(AccountService.chatHistory(params: chatHistoryRequest.toParams()),
            onSuccess: { (networkResponse) in
                do {
                    let transactions: [Transaction] = try Transaction.createArray(from: networkResponse.body!)
                    onSuccess(transactions)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (responseError) in
                onFailure((self.errorParser?.getError(networkError: responseError))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    func reactToPayment(transaction: Transaction, interaction: Interaction, onSuccess: @escaping (Transaction) -> Void, onFailure: @escaping (ApiError) -> Void) {
        guard let transactionId = transaction.identifier, let interactionId = interaction.id else { return }
        let interactionTransferModel = InteractionTransferModel(transactionId: transactionId, interactionId: interactionId)
        do {
            try apiService?.request(PaymentService.react(parameters: interactionTransferModel.toParams()), onSuccess: { (networkResponse) in
                do {
                    let reactionResponse = try PaymentReactionResponse.create(from: networkResponse.body!)
                    let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
                    let transactionInteraction = TransactionInteraction(interaction: interaction, date: reactionResponse.reactedAt, reactedBy: AccountManager.sharedInstance.getMachId(), availableAt: nil, triesRemaining: nil)
                    try realm.write {
                        transaction.addTransactionInteraction(transactionInteraction: transactionInteraction)
                    }
                    onSuccess(transaction)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (responseError) in
                onFailure((self.errorParser?.getError(networkError: responseError))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    func remindTransaction(transaction: Transaction, interaction: Interaction, onSuccess: @escaping (Transaction) -> Void, onFailure: @escaping (ApiError) -> Void) {
        guard let transactionId = transaction.identifier, let interactionId = interaction.id else { return }
        let interactionTransferModel = InteractionTransferModel(transactionId: transactionId, interactionId: interactionId)
        do {
            try apiService?.request(RequestService.remind(parameters: interactionTransferModel.toParams()), onSuccess: { (networkResponse) in
                do {
                    let reminderResponse = try RequestReminderResponse.create(from: networkResponse.body!)
                    let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
                    let transactionInteraction = TransactionInteraction(interaction: interaction, date: reminderResponse.remindedAt, reactedBy: AccountManager.sharedInstance.getMachId(), availableAt: reminderResponse.availableAt, triesRemaining: reminderResponse.triesRemaining)
                    try realm.write {
                        transaction.addTransactionInteraction(transactionInteraction: transactionInteraction)
                    }
                    onSuccess(transaction)

                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (responseError) in
                onFailure((self.errorParser?.getError(networkError: responseError))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
}
