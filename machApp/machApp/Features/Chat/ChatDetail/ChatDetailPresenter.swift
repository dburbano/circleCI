//
//  ChatDetailPresenter.swift
//  machApp
//
//  Created by lukas burns on 4/7/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class ChatDetailPresenter: ChatDetailPresenterProtocol {

    let maximumReminders: Int = 3

    weak var view: ChatDetailViewProtocol?
    var repository: ChatDetailRepositoryProtocol?

    var transactionsNotificationToken: NotificationToken?
    var machMessagesNotificationToken: NotificationToken?
    var groupViewModel: GroupViewModel?
    var chatMessagesDictionary: [Date: [ChatMessageBaseViewModel]] = [:]
    var chatMessagesSectionTitles: [Date] = []

    required init(repository: ChatDetailRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: ChatDetailViewProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        SegmentAnalytics.Event.chatgroupAccessed(machId: getMachID(), contactName: getGroupName(), groupId: groupViewModel?.group?.identifier ?? "").track()
    }
    
    func setGroupViewModel(_ groupViewModel: GroupViewModel?) {
        self.groupViewModel = groupViewModel
        self.hideChargePayButtonfUserNotInContacts()
        self.registerRealmChanges()
    }

    func markChatMessagesAsSeen() {
        self.groupViewModel?.markChatMessagesAsSeen()
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func registerRealmChanges() {
        transactionsNotificationToken = groupViewModel?.group?.transactions.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self?.loadChatMessages(animated: false, scrollToBottom: false)
            case .update(_, _, let insertions, let modifications):
                var wasTableViewUpdated = false
                for indexInserted in insertions {
                    // swiftlint:disable:next force_unwrapping for_where
                    if !(self?.groupViewModel?.group?.transactions[indexInserted].seen)! {
                        self?.loadChatMessages(animated: true, scrollToBottom: true)
                        wasTableViewUpdated = true
                        return
                    }
                }
                for indexModified in modifications {
                    // swiftlint:disable:next force_unwrapping for_where
                    if !(self?.groupViewModel?.group?.transactions[indexModified].seen)! {

                        self?.loadChatMessages(animated: true, scrollToBottom: true)
                        wasTableViewUpdated = true
                        return
                    }
                }
                if !wasTableViewUpdated {
                    self?.loadChatMessages(animated: true, scrollToBottom: false)
                }
            case .error(let error):
                print(error)
            }
        }

        machMessagesNotificationToken = groupViewModel?.group?.machMessages.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self?.loadChatMessages(animated: false, scrollToBottom: false)
            case .update(_, _, let insertions, let modifications):
                var wasTableViewUpdated = false
                for indexInserted in insertions {
                    // swiftlint:disable:next force_unwrapping for_where
                    if !(self?.groupViewModel?.group?.machMessages[indexInserted].seen)! {
                        self?.loadChatMessages(animated: true, scrollToBottom: true)
                        wasTableViewUpdated = true
                        return
                    }
                }
                for indexModified in modifications {
                    // swiftlint:disable:next force_unwrapping for_where
                    if !(self?.groupViewModel?.group?.machMessages[indexModified].seen)! {
                        self?.loadChatMessages(animated: true, scrollToBottom: true)
                        wasTableViewUpdated = true
                        return
                    }
                }
                if !wasTableViewUpdated {
                    self?.loadChatMessages(animated: true, scrollToBottom: false)
                }
            case .error(let error):
                print(error)
            }
        }
    }

    private func loadChatMessages(animated: Bool, scrollToBottom: Bool) {
        self.groupViewModel?.updateTransactionViewModels()
        self.groupViewModel?.updateMachMessagesViewModels()
        createTransactionsDictionary()
        self.view?.updateChatMessages(scrollToBottom: scrollToBottom)
    }

    private func createTransactionsDictionary() {
        chatMessagesDictionary = [:]
        chatMessagesSectionTitles = []
        guard let transactions = groupViewModel?.transactions else { return }
        for transaction in transactions {
            if let transacationKey = transaction.updatedAt?.dateWithoutTime() {
                if chatMessagesDictionary.has(transacationKey) {
                    chatMessagesDictionary[transacationKey]?.append(transaction)
                } else {
                    chatMessagesDictionary[transacationKey] = [transaction]
                }
            }
        }
        guard let machMessages = groupViewModel?.machMessages else { return }
        for machMessage in machMessages {
            if let machMessageKey = machMessage.updatedAt?.dateWithoutTime() {
                if chatMessagesDictionary.has(machMessageKey) {
                    chatMessagesDictionary[machMessageKey]?.append(machMessage)
                } else {
                    chatMessagesDictionary[machMessageKey] = [machMessage]
                }
            }
        }
        for dictionary in chatMessagesDictionary {
            chatMessagesDictionary[dictionary.key] = dictionary.value.sorted(by: { (a, b) -> Bool in
                return a.updatedAt!.compare(b.updatedAt!) == .orderedDescending
            })
        }
        chatMessagesSectionTitles = [Date](chatMessagesDictionary.keys)
        // Because elements are populated from bottom to top, we order them from newest to oldest.
        chatMessagesSectionTitles = chatMessagesSectionTitles.sorted(by: { return $0 > $1 })
    }

    func getNumberOfSections() -> Int {
        return chatMessagesSectionTitles.count
    }

    func getTitleForChatMessageSection(_ section: Int) -> String {
        return chatMessagesSectionTitles[section].getShortAndRelativeStringForDate()
    }

    func getNumberOfChatMessagesForSection(_ section: Int) -> Int {
        let sectionKey = chatMessagesSectionTitles[section]
        guard let chatMessages = chatMessagesDictionary[sectionKey] else { return 0 }
        return chatMessages.count
    }

    func getGroupName() -> String {
        guard let groupViewModel = groupViewModel else { return "Unknown" }
        if groupViewModel.isTransactionMadeByProximityAndUserNotInContact() || groupViewModel.isChatMessagesPopulated() {
            return "\(groupViewModel.users.first?.machFirstName ?? "") \(groupViewModel.users.first?.machLastName ?? "")"
        } else {
            return "\(groupViewModel.users.first?.firstNameToShow ?? "") \(groupViewModel.users.first?.lastNameToShow ?? "")"
        }
    }
    
    func getMachID() -> String {
        guard let groupViewModel = groupViewModel else { return "Unknown" }
        return groupViewModel.users.first?.machId ?? ""
    }

    func getChatMessage(indexPath: IndexPath) -> ChatMessageTuple? {
        guard let chatMessageSectionKey = chatMessagesSectionTitles.get(at: indexPath.section) else { return nil }
        guard let chatMessageViewModel = chatMessagesDictionary[chatMessageSectionKey]?[indexPath.row] else { return nil }
        //If ...fromUser.machId == ConfigurationManager.sharedInstance...machId that means this is a mach<->user transaction
        guard let machId = ConfigurationManager.sharedInstance.getMachTeamConfiguration()?.machId, machId == chatMessageViewModel.fromUser?.machId else {
            return ChatMessageTuple(chatMessageViewModel: chatMessageViewModel, tooltipFlag: true)
        }
        //We need to cast chatMessageViewModel so we can get its status
        guard let castedViewModel = chatMessageViewModel as? TransactionViewModel else { return ChatMessageTuple(chatMessageViewModel: chatMessageViewModel, tooltipFlag: true) }
        //This can be tricky, but the flag is going to be used in the isHidden variable. Therefore false means to show and true the opposite
        if castedViewModel.getTransactionStatus() == .pending {
            return ChatMessageTuple(chatMessageViewModel: chatMessageViewModel, tooltipFlag: false)
        } else {
            return ChatMessageTuple(chatMessageViewModel: chatMessageViewModel, tooltipFlag: true)
        }
    }

    func scrollToLastChatMessage(animated: Bool) {
        let indexPath = IndexPath(item: 0, section: 0)
        self.view?.scrollToChatMessage(at: indexPath, animated: animated)
    }

    func acceptRequest(indexPath: IndexPath) {
        guard (getChatMessage(indexPath: indexPath)?.chatMessageViewModel as? TransactionViewModel) != nil else { return }
        self.view?.presentPasscode(title: "Ingresa tu PIN para confirmar el pago de \(getChatMessage(indexPath: indexPath)?.chatMessageViewModel.amount.toCurrency() ?? "")", onSuccess: {
            self.executeAcceptance(indexPath: indexPath)
        })
    }

    private func executeAcceptance(indexPath: IndexPath) {
        guard let transactionViewModel = getChatMessage(indexPath: indexPath)?.chatMessageViewModel as? TransactionViewModel else { return }
        self.view?.blockActionsForTransactionReceived(at: indexPath)
        self.repository?.acceptTransaction(transaction: transactionViewModel.transaction, onSuccess: { (returnedTransaction) in
            returnedTransaction.markAsNotSeen()
            self.view?.unblockActionsForTransactionReceived(at: indexPath)
        }, onFailure: { (error) in
            self.view?.unblockActionsForTransactionReceived(at: indexPath)
            self.handle(error: error, showDefaultError: true)
        })
    }

    func rejectRequest(indexPath: IndexPath, interactionViewModel: InteractionViewModel) {
        guard (getChatMessage(indexPath: indexPath)?.chatMessageViewModel as? TransactionViewModel) != nil else { return }
        self.executeRejection(indexPath: indexPath, interaction: interactionViewModel.interaction)
    }

    private func executeRejection(indexPath: IndexPath, interaction: Interaction) {
        guard let transactionViewModel = getChatMessage(indexPath: indexPath)?.chatMessageViewModel as? TransactionViewModel else { return }
        self.view?.blockActionsForTransactionReceived(at: indexPath)
        self.repository?.rejectTransaction(transaction: transactionViewModel.transaction, interaction: interaction, onSuccess: { (returnedTransaction) in
            returnedTransaction.markAsNotSeen()
            self.view?.unblockActionsForTransactionReceived(at: indexPath)
        }, onFailure: { (error) in
            self.view?.unblockActionsForTransactionReceived(at: indexPath)
            self.handle(error: error, showDefaultError: true)
        })
    }

    func cancelRequest(indexPath: IndexPath) {
        guard (getChatMessage(indexPath: indexPath)?.chatMessageViewModel as? TransactionViewModel) != nil else { return }
        self.view?.showCancelationConfirmationAlert(groupName: self.getGroupName(), amount: self.getChatMessage(indexPath: indexPath)?.chatMessageViewModel.amount ?? 0, onAccepted: {
            self.executeCancelation(indexPath: indexPath)
        }, onCancelled: {
        })
    }

    private func executeCancelation(indexPath: IndexPath) {
        guard let transactionViewModel = getChatMessage(indexPath: indexPath)?.chatMessageViewModel as? TransactionViewModel else { return }
        self.view?.blockActionsForTransactionSent(at: indexPath)
        self.repository?.cancelTransaction(transaction: transactionViewModel.transaction, onSuccess: { (returnedTransaction) in
            returnedTransaction.markAsNotSeen()
            self.view?.unblockActionsForTransactionSent(at: indexPath)
        }, onFailure: { (error) in
            self.view?.unblockActionsForTransactionSent(at: indexPath)
            self.handle(error: error, showDefaultError: true)
        })
    }

    func remindButtonSelected(at indexPath: IndexPath) {
        guard let transactionViewModel = getChatMessage(indexPath: indexPath)?.chatMessageViewModel as? TransactionViewModel else { return }
        if transactionViewModel.getLastInteraction() == nil {
            self.view?.showSelectInteractionView(for: indexPath)
            return
        }
        if transactionViewModel.transaction.transactionInteractions.count < self.maximumReminders {
            self.view?.showSelectInteractionView(for: indexPath)
        } else {
            self.view?.showTooManyReminderAttemptsError(maximumReminders: self.maximumReminders)
        }
    }

    func remindRequest(indexPath: IndexPath, interactionViewModel: InteractionViewModel) {
        guard let transactionViewModel = getChatMessage(indexPath: indexPath)?.chatMessageViewModel as? TransactionViewModel else { return }
        self.repository?.remindTransaction(transaction: transactionViewModel.transaction, interaction: interactionViewModel.interaction, onSuccess: { _ in
            if !AccountManager.sharedInstance.hasRequestReminderInformationBeenShown() {
                self.view?.showReminderInformationView()
                AccountManager.sharedInstance.setHasRequestReminderInformationBeenShown(with: true)
            }
        }, onFailure: { (error) in
            self.handle(error: error, showDefaultError: true)
        })
    }

    func reactToTransaction(indexPath: IndexPath, interactionViewModel: InteractionViewModel) {
        guard let transactionViewModel = getChatMessage(indexPath: indexPath)?.chatMessageViewModel as? TransactionViewModel else { return }
        self.repository?.reactToPayment(transaction: transactionViewModel.transaction, interaction: interactionViewModel.interaction,
                                        onSuccess: { _ in },
                                        onFailure: { (error) in
            self.handle(error: error, showDefaultError: true)
        })
    }

    // MARK: - Private
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let chatDetailError):
            guard let chatDetailError = chatDetailError as? ChatDetailError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch chatDetailError {
            default:
                break
            }
        case .clientError(let chatDetailError):
            guard let chatDetailError = chatDetailError as? ChatDetailError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch chatDetailError {
            case .insufficientBalance:
                self.view?.showInsufficientBalanceError()
            case .frequentReminders:
                self.view?.showTooFrequentReminderErrror(remindersUsed: 1, maximumReminders: maximumReminders)
            case .tooManyRemindersSent:
                self.view?.showTooManyReminderAttemptsError(maximumReminders: maximumReminders)
            }
        case .smyteError(let message):
            self.view?.showBlockedAction(with: message)
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }

    func createNewPayment() {
        self.view?.navigateToNewTransaction(transactionMode: .payment)
    }

    func createNewRequest() {
        self.view?.navigateToNewTransaction(transactionMode: .request)
    }

    func getUserAmountViewModels() -> [UserAmountViewModel] {
        var userAmountViewModels: [UserAmountViewModel] = []
        guard let userViewModels = self.groupViewModel?.users else { return userAmountViewModels }
        for userViewModel in userViewModels {
            userAmountViewModels.append(UserAmountViewModel(user: userViewModel.user))
        }
        return userAmountViewModels
    }

    func userScrolledToTopOfChat() {
        guard let groupViewModel = groupViewModel, !groupViewModel.isChatMessagesPopulated() else { return }
        let oldestTransaction = groupViewModel.group?.getOldestTransaction()
        self.view?.showActivityIndicator()
        self.repository?.getChatHistory(before: oldestTransaction, onSuccess: { (transactions) in
            for transaction in transactions {
                transaction.seen = true
                do {
                    try TransactionManager.handleTransactionReceived(transaction: transaction)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                }
            }
            self.view?.hideActivityIndicator()
        }, onFailure: { (error) in
            self.handle(error: error)
            self.view?.hideActivityIndicator()
        })
    }

    private func getLastIndexPath() -> IndexPath {
        guard let lastSectionTitle = chatMessagesSectionTitles.last else {
            return IndexPath(row: 0, section: 0)
        }
        let lastSection = chatMessagesSectionTitles.count - 1
        let lastRow = ((chatMessagesDictionary[lastSectionTitle]?.count) ?? 0) - 1
        let indexPath = IndexPath(item: lastRow, section: lastSection)
        return indexPath
    }

    private func hideChargePayButtonfUserNotInContacts() {
        guard let groupViewModel = groupViewModel, let machId = groupViewModel.users[0].machId,
            let machTeamId = ConfigurationManager.sharedInstance.getMachTeamConfiguration()?.machId else { return }
        if groupViewModel.isTransactionMadeByProximityAndUserNotInContact() || groupViewModel.isChatMessagesPopulated() || machId == machTeamId {
            self.view?.hideMoreOptions()
        }
    }

}
