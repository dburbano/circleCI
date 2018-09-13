//
//  ChatDetailContracts.swift
//  machApp
//
//  Created by lukas burns on 4/7/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

typealias ChatMessageTuple = (chatMessageViewModel: ChatMessageBaseViewModel, tooltipFlag: Bool)

protocol ChatDetailViewProtocol: BaseViewProtocol {

    func updateChatMessages(scrollToBottom: Bool)

    func updateChatMessageAt(indexPath: IndexPath)

    func scrollToChatMessage(at indexPath: IndexPath, animated: Bool)

    func showRejectionConfirmationAlert(groupName: String, amount: Int, onAccepted: @escaping() -> Void, onCancelled: @escaping() -> Void)

    func showCancelationConfirmationAlert(groupName: String, amount: Int, onAccepted: @escaping() -> Void, onCancelled: @escaping() -> Void)

    func presentPasscode(title: String, onSuccess: @escaping() -> Void)

    func navigateToNewTransaction(transactionMode: TransactionMode)

    func showActivityIndicator()

    func hideActivityIndicator()

    func blockActionsForTransactionReceived(at indexPath: IndexPath)

    func unblockActionsForTransactionReceived(at indexPath: IndexPath)

    func blockActionsForTransactionSent(at indexPath: IndexPath)

    func unblockActionsForTransactionSent(at indexPath: IndexPath)

    func hideMoreOptions()

    func showInsufficientBalanceError()

    func showReminderInformationView()

    func showTooManyReminderAttemptsError(maximumReminders: Int)

    func showTooFrequentReminderErrror(remindersUsed: Int, maximumReminders: Int)

    func showSelectInteractionView(for indexPath: IndexPath)

    func showGenericError(with message: String)

    func showBlockedAction(with message: String)
}

protocol ChatDetailPresenterProtocol: BasePresenterProtocol {

    func setView(view: ChatDetailViewProtocol)

    func markChatMessagesAsSeen()

    func setGroupViewModel(_ groupViewModel: GroupViewModel?)

    func getGroupName() -> String

    func getChatMessage(indexPath: IndexPath) -> ChatMessageTuple?

    func getNumberOfChatMessagesForSection(_ section: Int) -> Int

    func getNumberOfSections() -> Int

    func getTitleForChatMessageSection(_ section: Int) -> String

    func acceptRequest(indexPath: IndexPath)

    func rejectRequest(indexPath: IndexPath, interactionViewModel: InteractionViewModel)

    func cancelRequest(indexPath: IndexPath)

    func scrollToLastChatMessage(animated: Bool)

    func createNewPayment()

    func createNewRequest()

    func getUserAmountViewModels() -> [UserAmountViewModel]

    func userScrolledToTopOfChat()

    func remindRequest(indexPath: IndexPath, interactionViewModel: InteractionViewModel)

    func reactToTransaction(indexPath: IndexPath, interactionViewModel: InteractionViewModel)

    func remindButtonSelected(at indexPath: IndexPath)
    
    func viewDidLoad()

}

protocol ChatDetailRepositoryProtocol {

    func updateTransactions(_ transactions: List<Transaction>)

    func getTransactionsSortedByDate(groupIdentifier: String, onSuccess: @escaping (Results<Transaction>) -> Void, onFailure: @escaping (ApiError) -> Void)

    func getMachMessagesSortedByDate(groupIdentifier: String, onSuccess: @escaping (Results<MachMessage>) -> Void, onFailure: @escaping (ApiError) -> Void)

    func acceptTransaction(transaction: Transaction, onSuccess: @escaping (Transaction) -> Void, onFailure: @escaping (ApiError) -> Void)

    func rejectTransaction(transaction: Transaction, interaction: Interaction, onSuccess: @escaping (Transaction) -> Void, onFailure: @escaping (ApiError) -> Void)

    func cancelTransaction(transaction: Transaction, onSuccess: @escaping (Transaction) -> Void, onFailure: @escaping (ApiError) -> Void)

    func getChatHistory(before transaction: Transaction?, onSuccess: @escaping ([Transaction]) -> Void, onFailure: @escaping (ApiError) -> Void)

    func reactToPayment(transaction: Transaction, interaction: Interaction, onSuccess: @escaping (Transaction) -> Void, onFailure: @escaping (ApiError) -> Void)

    func remindTransaction(transaction: Transaction, interaction: Interaction, onSuccess: @escaping (Transaction) -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum ChatDetailError: Error {
    case insufficientBalance(message: String)
    case frequentReminders(message: String)
    case tooManyRemindersSent(message: String)
}

class ChatDetailErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "processor_insufficient_balance" {
            return ApiError.clientError(error: ChatDetailError.insufficientBalance(message: ""))
        } else if networkError.errorType == "social_reminder_too_frequent_tries" {
            return ApiError.clientError(error: ChatDetailError.frequentReminders(message: ""))
        } else if networkError.errorType == "social_reminder_too_many_tries" {
            return ApiError.clientError(error: ChatDetailError.tooManyRemindersSent(message: ""))
        } else {
            return super.getError(networkError: networkError)
        }
    }
}
