//
//  ReactionDelegate.swift
//  machApp
//
//  Created by lukas burns on 10/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol OpenInteractionsDelegate {
    func reactTo(cell: PaymentReceivedTableViewCell)
    
    func reactTo(requestCell: RequestSentTableViewCell)

    func remindTo(cell: RequestSentTableViewCell)
}

protocol InteractionTappedDelegate {

    func interactionTapped(cell: InteractionTableViewCell)
}

protocol InteractionSelectedDelegate {

    func reminderSelected(interactionViewModel: InteractionViewModel, transactionIndexPath: IndexPath?)
    
    func rejectionSelected(interactionViewModel: InteractionViewModel, transactionIndexPath: IndexPath?)
    
    func reactionSelected(interactionViewModel: InteractionViewModel, transactionIndexPath: IndexPath?)
}
