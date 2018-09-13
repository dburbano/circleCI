//
//  Navigator.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class Navigator {
    static let shared = Navigator()

    lazy var repository = NavigatorRepository()
    
    lazy var tabVC: TabBarViewController? = {
        return UIStoryboard(name: "TabBar", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController
    }()

    private init() {}

    func proceedToDeeplink(type: DeeplinkType) {
        setRootViewController()
        
        switch type {
        case .openProfile:
            handleProfile()
        case .openShare:
            handleShare()
        case .openCashIn:
           self.navigateToCashIn()
        case .openGroup(let groupId):
            handleGroup(with: groupId)
        case .openMovement(let groupId, let movementId):
            handleChatDetail(with: groupId, movementId: movementId)
        case .openMore():
            selectMore(with: false)
        case .openHome():
            selectHomeTab()
        case .pay(let userId, let amount, let comment):
            handlePayment(userId: userId, amount: amount, comment: comment)
        case .request(let userId, let amount, let comment):
            handleRequest(userId: userId, amount: amount, comment: comment)
        }
    }
    
    //MARK: Profile
    private func handleProfile() {
        repository.updateUser(onSuccess: {[weak self] in
            self?.navigateToProfile()
            }, onFailure: {[weak self] in
                self?.showAlert()
        })
    }
    
    private func navigateToProfile() {
        selectMore(with: false)
        guard let lastVC = UIApplication.topViewController() as? MoreViewController
            else { return }
        lastVC.performSegue(withIdentifier: "showProfile", sender: nil)
    }
    
    //MARK: Share
    
    private func handleShare() {
        selectMore(with: true)
    }
    
    //MARK: Cashin
    private func navigateToCashIn() {
        selectChargeTab()
    }
    
    //MARK: Group
    private func handleGroup(with groupID: String) {
        if let groupVM = repository.getGroup(with: groupID) {
            navigateToChatDetail(with: groupVM)
        } else {
            repository.getChatHistory(with: groupID, onSuccess: {[weak self] transactions in
                self?.saveNew(transactions: transactions)
                if let groupViewModel = self?.repository.getGroup(with: groupID) {
                    self?.navigateToChatDetail(with: groupViewModel)}
                }, onFailure: {})
        }
    }
    
    private func saveNew(transactions: [Transaction]) {
        for transaction in transactions {
            transaction.seen = true
            do {
                try TransactionManager.handleTransactionReceived(transaction: transaction)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
            }
        }
    }
    
    //MARK: Chat detail
    private func handleChatDetail(with groupId: String, movementId: String) {
        guard let groupVM = repository.getGroup(with: groupId) else { return }
        if repository.getTransaction(with: movementId) != nil {
            navigateToChatDetail(with: groupVM)
        } else {
            // Fallback when group doesnt exist
            repository.getTransaction(with: MovementTransferModel(id: movementId), onSuccess: {
                if let groupVM = self.repository.getGroup(with: groupId) {
                    self.navigateToChatDetail(with: groupVM)
                }
            }, onFailure: {
                self.showAlert()
            })
        }
    }
    
    private func navigateToChatDetail(with groupViewModel: GroupViewModel) {
        selectHomeTab()
        guard let tabVC = tabVC,
        let chatDetailVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ChatDetailViewController") as? ChatDetailViewController
            else { return }
        chatDetailVC.groupViewModel = groupViewModel
        tabVC.selectedViewController?.childViewControllers.last?.pushVC(chatDetailVC)
    }
    
    //MARK: Payment
    private func handlePayment(userId: String, amount: Int?, comment: String?) {
        if let userAmountViewModel = repository.getUser(with: userId) {
            self.navigateToPayment(userAmountViewModel: userAmountViewModel, amount: amount, comment: comment)
        } else {
            self.repository.getUser(with: userId, onSuccess: { (user) in
                self.navigateToPayment(userAmountViewModel: UserAmountViewModel(user: user), amount: amount, comment: comment)
            }, onFailure: {})
        }
    }
    
    private func navigateToPayment(userAmountViewModel: UserAmountViewModel, amount: Int?, comment: String?) {
        selectHomeTab()
        SegmentAnalytics.Event.paymentFlowStarted(location: SegmentAnalytics.EventParameter.LocationType().navbar, method: SegmentAnalytics.EventParameter.PhoneMethod().link).track()
        guard let tabVC = tabVC,
            let selectAmountViewController = UIStoryboard(name: "Transaction", bundle: nil).instantiateViewController(withIdentifier: "SelectAmountViewController") as? SelectAmountViewController
            else { return }
            selectAmountViewController.transactionMode = TransactionMode.payment
            selectAmountViewController.userAmountViewModels = [userAmountViewModel]
            selectAmountViewController.previouslySetMessage = comment ?? ""
            selectAmountViewController.previouslySetAmount = amount
            selectAmountViewController.viewMode = ViewMode.deeplinkTransaction
            let navigationController = UINavigationController(rootViewController: selectAmountViewController)
            tabVC.selectedViewController?.childViewControllers.last?.presentVC(navigationController)
    }
    
    //MARK: Request
    private func handleRequest(userId: String, amount: Int?, comment: String?) {
        if let userAmountViewModel = repository.getUser(with: userId) {
            self.navigateToRequest(userAmountViewModel: userAmountViewModel, amount: amount, comment: comment)
        } else {
            self.repository.getUser(with: userId, onSuccess: { (user) in
                self.navigateToRequest(userAmountViewModel: UserAmountViewModel(user: user), amount: amount, comment: comment)
            }, onFailure: {})
        }
    }
    
    private func navigateToRequest(userAmountViewModel: UserAmountViewModel, amount: Int?, comment: String?) {
        selectHomeTab()
        SegmentAnalytics.Event.requestFlowStarted(location: SegmentAnalytics.EventParameter.LocationType().navbar, method: SegmentAnalytics.EventParameter.PhoneMethod().link).track()
        guard let tabVC = tabVC,
            let selectAmountViewController = UIStoryboard(name: "Transaction", bundle: nil).instantiateViewController(withIdentifier: "SelectAmountViewController") as? SelectAmountViewController
            else { return }
            selectAmountViewController.transactionMode = TransactionMode.request
            selectAmountViewController.userAmountViewModels = [userAmountViewModel]
            selectAmountViewController.previouslySetMessage = comment ?? ""
            selectAmountViewController.previouslySetAmount = amount
            selectAmountViewController.viewMode = ViewMode.deeplinkTransaction
            let navigationController = UINavigationController(rootViewController: selectAmountViewController)
            tabVC.selectedViewController?.childViewControllers.last?.presentVC(navigationController)
    }

    //MARK: Aux methods
    private func setRootViewController() {
        guard let tabVC = tabVC else { return }
        UIApplication.shared.keyWindow?.rootViewController = tabVC
    }

    private func selectMore(with flag: Bool) {
        guard let tabVC = tabVC else { return }
        tabVC.selectTab(tag: TabBarViewController.TabTag.home)
        guard let moreVC = UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: "MoreViewController") as? MoreViewController
            else { return }
        if flag {
            moreVC.shouldPresentShare = true
        }
        let navVC = SwipeNavigationController(rootViewController: moreVC)
        moreVC.hidesBottomBarWhenPushed = true
        tabVC.selectedViewController?.childViewControllers.last?.presentVC(navVC)
    }
    
    private func selectHomeTab() {
        guard let tabVC = tabVC else { return }
        tabVC.selectTab(tag: TabBarViewController.TabTag.home)
    }
    
    private func selectChargeTab() {
        guard let tabVC = tabVC else { return }
        tabVC.selectTab(tag: TabBarViewController.TabTag.charge)
    }

    private func showAlert() {
        let alertController = UIAlertController.init(title: nil, message: "No hemos podido descargar el movimiento que te llegó en la push notification", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            vc.presentVC(alertController)
        }
    }
}
