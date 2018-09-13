//
//  ReactionPresenter.swift
//  machApp
//
//  Created by lukas burns on 10/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class InteractionPresenter: InteractionPresenterProtocol {

    weak var view: InteractionViewProtocol?
    var repository: InteractionRepositoryProtocol?

    var interactionType: InteractionType?
    var transactionIndexPath: IndexPath?

    var interactionViewModels: [InteractionViewModel] = []

    required init(repository: InteractionRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: InteractionViewProtocol) {
        self.view = view
    }

    func setupMenu(interactionType: InteractionType?, transactionIndexPath: IndexPath?) {
        self.interactionType = interactionType
        self.transactionIndexPath = transactionIndexPath
        self.setTitle()
        self.loadInteractions()
    }

    func loadInteractions() {
        guard let interactionType = self.interactionType else { return }
        switch interactionType {
        case .paymentReactionInteraction:
            self.repository?.getReceivedPaymentInteractions(onSuccess: { (interactionsResult) in
                self.interactionViewModels = interactionsResult.map({ (interaction) -> InteractionViewModel in
                    return InteractionViewModel(interaction: interaction)
                })
                self.view?.reloadInteractions()
            }, onFailure: { (error) in
                print(error.localizedDescription)
            })
        case .requestRejectionInteraction:
            self.repository?.getRequestRejectedInteractions(onSuccess: { (interactionsResult) in
                self.interactionViewModels = interactionsResult.map({ (interaction) -> InteractionViewModel in
                    return InteractionViewModel(interaction: interaction)
                })
                self.view?.reloadInteractions()
            }, onFailure: { (error) in
                print(error.localizedDescription)
            })
        case .requestReminderInteraction:
            self.repository?.getRequestReminderInteractions(onSuccess: { (interactionsResult) in
                self.interactionViewModels = interactionsResult.map({ (interaction) -> InteractionViewModel in
                    return InteractionViewModel(interaction: interaction)
                })
                self.view?.reloadInteractions()
            }, onFailure: { (error) in
                print(error.localizedDescription)
            })
        }
    }

    func getNumberOfInteractions() -> Int {
        return interactionViewModels.count
    }

    func getInteraction(at index: IndexPath) -> InteractionViewModel? {
        return interactionViewModels.get(at: index.row)
    }

    func interactionSelected(at index: IndexPath) {
        guard let interaction = interactionViewModels.get(at: index.row), let interactionType = self.interactionType else { return }
        switch interactionType {
        case .paymentReactionInteraction:
            self.view?.reacted(with: interaction, transactionIndexPath: self.transactionIndexPath)
        case .requestRejectionInteraction:
            self.view?.rejected(with: interaction, transactionIndexPath: self.transactionIndexPath)
        case .requestReminderInteraction:
            self.view?.reminded(with: interaction, transactionIndexPath: self.transactionIndexPath)
        }
        self.view?.closeInteractionView()
        
    }

    private func setTitle() {
        guard let interactionType = self.interactionType else { return }
        switch interactionType {
        case .paymentReactionInteraction:
            self.view?.setPaymentReceivedInteractionTitle()
        case .requestRejectionInteraction:
            self.view?.setRequestRejectedInteractionTitle()
        case .requestReminderInteraction:
            self.view?.setRequestReminderInteractionTitle()
        }
    }

}
