//
//  HistoryViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/2/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class HistoryViewController: BaseViewController {

    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var transactionsFilterButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    let filterSegue = "TransactionsFilterSegue"
    let zendeskArticleName = "filter_historial"
    let showMACHCardInforation = "showMACHCardInformation"

    // MARK: - Variables
    var presenter: HistoryPresenterProtocol?
    var transactionsViewController: TransactionsHistoryViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.getBalance()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        topContainerView.setMachGradient(includesStatusBar: true, navigationBar: nil, withRoundedBottomCorners: true, withShadow: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is HistoryMonthsViewController {
            if let destinationVC = segue.destination as? HistoryMonthsViewController {
                destinationVC.delegate = self
            }
        } else if segue.destination is TransactionsHistoryViewController {
            if let destinationVC = segue.destination as? TransactionsHistoryViewController {

                //The first time the table is going to be displayed, it has to be set to all movements filter.
                destinationVC.filter = .allMovements
                destinationVC.delegate = self
                transactionsViewController = destinationVC
            }
        } else if segue.destination is TransactionsFilterViewController {
            if let destinationVC = segue.destination as? TransactionsFilterViewController {
                destinationVC.delegate = self
                destinationVC.selectedFilter = transactionsViewController?.filter
            }
        }
    }

    // MARK: Actions
    @IBAction func unwindToHistoryVC(segue: UIStoryboardSegue) {}

    @IBAction func didPressBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func didPressFilter(_ sender: Any) {
        performSegue(withIdentifier: filterSegue, sender: nil)
    }

    @IBAction func helpButtonTapped(_ sender: UIButton) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().helpbox, helpTagAccessed: self.zendeskArticleName).track()
    }

    // Private

    internal func showLoadingAnimation() {
        // Todo FIX this behavior when laoding two months and pressing one after the other, for now disable interaction.
        view.isUserInteractionEnabled = false
        activity.isHidden = false
        activity.startAnimating()
    }

    internal func hideLoadingAnimation() {
        // Todo FIX this behavior.
        view.isUserInteractionEnabled = true
        activity.stopAnimating()
    }
}

extension HistoryViewController: HistoryViewProtocol {
    func updateBalance(balance: String) {
        balanceLabel.text = balance
    }

    func showNoInternetConnectionError() {
        super.showGeneralErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }
}

extension HistoryViewController: HistoryMonthsDelegate {
    func didSelect(date: Date) {
        transactionsViewController?.dateFilter = date
        showLoadingAnimation()
    }

    func couldntLoadDates() {
        showServerError()
        //Block user interaction
        hideLoadingAnimation()
        view.isUserInteractionEnabled = true
    }
}

extension HistoryViewController: TransactionsFilterDelegate {
    func didSelect(filter: TransactionsFilter) {
        transactionsViewController?.filter = filter
        transactionsFilterButton.setTitle(filter.rawValue, for: .normal)
        showLoadingAnimation()
    }
}

extension HistoryViewController: TransactionsHistoryDelegate {
    func didFinishLoadingData() {
        hideLoadingAnimation()
    }

    func didNotLoadData() {
        hideLoadingAnimation()
        showServerError()
    }
    
    func couldNotLoadMoreData() {
        hideLoadingAnimation()
        super.showToastWithText(text: "No hemos podido cargar más movimientos. Intenta más tarde.")
    }
    
    func showMACHCardInformation() {
        self.performSegue(withIdentifier: showMACHCardInforation, sender: nil)
    }
}
