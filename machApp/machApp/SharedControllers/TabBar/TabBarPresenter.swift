//
//  TabBarPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class TabBarPresenter: TabBarPresenterProtocol {

    weak var view: TabBarViewProtocol?
    var repository: TabBarRepositoryProtocol?
    var historyGroupsViewModels: [GroupViewModel] = []
    var historyNotificationToken: NotificationToken?

    required init(repository: TabBarRepositoryProtocol?) {
        self.repository = repository
        //Create a listener so getHistory is executed every time Mach Profile is updated
        registerRealmChanges()
    }

    deinit {
        historyNotificationToken?.invalidate()
    }

    func setView(view: TabBarViewProtocol) {
        self.view = view
    }

    func getHistory() {
        repository?.getHistory(onSuccess: {[weak self] (groups) in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.historyGroupsViewModels = groups.map({ (group) -> GroupViewModel in
                return GroupViewModel(group: group)
            })
            }, onFailure: {})
    }

    func areThereTransactions() -> Bool {
        return historyGroupsViewModels.reduce(false, {
            return $0 || $1.isTransactionsPopulated()
        })
    }
    
    func getCreditCard() {
        view?.showLoadingIndicator(with: true)
        self.repository?.getPrepaidCards(onSuccess: {[weak self] prepaidCards in
            self?.view?.showLoadingIndicator(with: false)
            self?.view?.navigateToPrepaidCards(with: prepaidCards)
            }, onFailure: {[weak self] (error) in
                self?.view?.showLoadingIndicator(with: false)
                self?.handleCardError(error: error)
        })
    }

    private func registerRealmChanges() {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            historyNotificationToken = realm.objects(Group.self).observe { [weak self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial, .update:
                    self?.getHistory()
                case .error(let error):
                    print(error)
                }
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }
    
    private func handleCardError(error apiError: ApiError) {
        switch apiError {
        case .clientError(let cardError):
            guard let cardError = cardError as? TabError else { return }
            switch cardError {
            case .prepaidCardUserVerificationNeeded:
                 view?.navigateToStartAuthenticationProcess()
            default:
                repository?.getLocalPrepaidCards(onSuccess: {[weak self] (localPrepaidCards) in
                    if !localPrepaidCards.isEmpty {
                        self?.view?.navigateToPrepaidCards(with: localPrepaidCards)
                    } else {
                        self?.view?.showServerError()
                    }
                }, onFailure: {[weak self] in
                    self?.view?.showServerError()
                })
            }
        default:
            view?.showServerError()
        }
    }
}

extension TabBarPresenter: AuthenticationDelegate {
    func authenticationProcessClosed() {
        self.view?.dismissAuthenticationProcess()
    }
    
    func authenticationSucceeded() {
        self.view?.dismissAuthenticationProcess()
        self.getCreditCard()
    }
    
    func authenticationFailed() {
        self.view?.dismissAuthenticationProcess()
    }
    
}
