//
//  ReactionViewController.swift
//  machApp
//
//  Created by lukas burns on 10/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

enum InteractionType: String {
    case paymentReactionInteraction = "reaction"
    case requestRejectionInteraction = "rejection"
    case requestReminderInteraction = "reminder"
}

class InteractionViewController: BaseViewController {

    let showChatDetail: String = "showChatDetail"
    let interactionCellIdentifier: String = "interactionCellIdentifier"

    var presenter: InteractionPresenterProtocol?
    var interactionSelectedDelegate: InteractionSelectedDelegate?

    var interactionType: InteractionType?
    var transactionIndexPathInChat: IndexPath?

    @IBOutlet weak var interactionTitle: UILabel!
    @IBOutlet weak var interactionsTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        interactionsTable.register(UINib(nibName: "InteractionTableViewCell", bundle: nil), forCellReuseIdentifier: interactionCellIdentifier)
        self.presenter?.setupMenu(interactionType: interactionType, transactionIndexPath: transactionIndexPathInChat)
    }

//    func checkIfTableAllowScrolling() {
//        if reactionsTable.contentSize.height < reactionsTable.frame.size.height {
//            reactionsTable.isScrollEnabled = false
//        } else {
//            reactionsTable.isScrollEnabled = true
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}

extension InteractionViewController: InteractionViewProtocol {

    internal func setPaymentReceivedInteractionTitle() {
         self.interactionTitle.text = "Reacción al Pago"
    }

    internal func setRequestRejectedInteractionTitle() {
        self.interactionTitle.text = "¿Por qué quieres rechazar?"
    }

    internal func setRequestReminderInteractionTitle() {
        self.interactionTitle.text = "¿Cómo quieres recordarle?"
    }

    internal func closeInteractionView() {
        self.performSegue(withIdentifier: showChatDetail, sender: self)
    }

    internal func reloadInteractions() {
        self.interactionsTable.reloadData()
    }

    func reacted(with interactionViewModel: InteractionViewModel, transactionIndexPath: IndexPath?) {
        self.interactionSelectedDelegate?.reactionSelected(interactionViewModel: interactionViewModel, transactionIndexPath: transactionIndexPath)
    }

    func reminded(with interactionViewModel: InteractionViewModel, transactionIndexPath: IndexPath?) {
        self.interactionSelectedDelegate?.reminderSelected(interactionViewModel: interactionViewModel, transactionIndexPath: transactionIndexPath)
    }

    func rejected(with interactionViewModel: InteractionViewModel, transactionIndexPath: IndexPath?) {
        self.interactionSelectedDelegate?.rejectionSelected(interactionViewModel: interactionViewModel, transactionIndexPath: transactionIndexPath)
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }
}

extension InteractionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter?.getNumberOfInteractions() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let interaction = self.presenter?.getInteraction(at: indexPath) else { return UITableViewCell() }
        let cell = interactionsTable.dequeueReusableCell(withIdentifier: interactionCellIdentifier, for: indexPath) as! InteractionTableViewCell
        cell.setupCell(with: interaction)
        cell.interactionTappedDelegate = self
        return cell
    }
}

extension InteractionViewController: UITableViewDelegate {

}

extension InteractionViewController: InteractionTappedDelegate {

    func interactionTapped(cell: InteractionTableViewCell) {
        guard let indexPath = interactionsTable.indexPath(for: cell) else { return }
        self.presenter?.interactionSelected(at: indexPath)
    }
}
