//
//  ReactionContract.swift
//  machApp
//
//  Created by lukas burns on 10/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

protocol InteractionViewProtocol: BaseViewProtocol {

    func setPaymentReceivedInteractionTitle()

    func setRequestRejectedInteractionTitle()

    func setRequestReminderInteractionTitle()

    func closeInteractionView()

    func reloadInteractions()

    func reacted(with interactionViewModel: InteractionViewModel, transactionIndexPath: IndexPath?)

    func reminded(with interactionViewModel: InteractionViewModel, transactionIndexPath: IndexPath?)
    
    func rejected(with interactionViewModel: InteractionViewModel, transactionIndexPath: IndexPath?)
}

protocol InteractionPresenterProtocol: BasePresenterProtocol {

    func setView(view: InteractionViewProtocol)

    func setupMenu(interactionType: InteractionType?, transactionIndexPath: IndexPath?)

    func getNumberOfInteractions() -> Int

    func getInteraction(at index: IndexPath) -> InteractionViewModel?

    func interactionSelected(at index: IndexPath)

}

protocol InteractionRepositoryProtocol {

    func getReceivedPaymentInteractions(onSuccess: @escaping (Results<Interaction>) -> Void, onFailure: @escaping (ApiError) -> Void)

    func getRequestRejectedInteractions(onSuccess: @escaping (Results<Interaction>) -> Void, onFailure: @escaping (ApiError) -> Void)

    func getRequestReminderInteractions(onSuccess: @escaping (Results<Interaction>) -> Void, onFailure: @escaping (ApiError) -> Void)

}

class InteractionErrorParser: ErrorParser {

}
