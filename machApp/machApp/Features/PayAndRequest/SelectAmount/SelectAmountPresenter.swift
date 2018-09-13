//
//  SelectAmountPresenter.swift
//  machApp
//
//  Created by lukas burns on 3/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class SelectAmountPresenter: SelectAmountPresenterProtocol {
    
    var view: SelectAmountViewProtocol?
    var repository: SelectAmountRepositoryProtocol?
    var viewMode: ViewMode? {
        didSet {
            guard let viewMode = viewMode, !users.isEmpty else { return }
            switch viewMode {
            case .chargeMach:
                if let amount = users[0].maximumAmount {
                    view?.updateTooltipCanChargeMoreLabel(with: "Nos puedes cobrar hasta \(amount.toCurrency()) 😎")
                    view?.showTooltipCanChargeMore(with: false)
                }
            default: break
            }
        }
    }
    
    var balance: Int
    var users: [UserAmountViewModel] = []
    var message: String = ""
    var transactionMode: TransactionMode?
    var totalAmount: Int?
    var splitCountingUser: Bool = false
    var userAmount: Int = 0
    
    let maximumTransactionAmount: Int = 500000
    
    required init(repository: SelectAmountRepositoryProtocol?) {
        self.repository = repository
        self.balance = 0
    }
    
    func setView(view: SelectAmountViewProtocol) {
        self.view = view
    }
    
    func setUsers(_ userAmountViewModels: [UserAmountViewModel]?) {
        if let users = userAmountViewModels {
            self.users = users
            showDivideTooltip()
        }
    }
    
    func setTransactionMode(_ transactionMode: TransactionMode?) {
        self.transactionMode = transactionMode
    }
    
    func getUser(for indexPath: IndexPath) -> UserAmountViewModel? {
        return users[indexPath.row]
    }
    
    func getAllUsers() -> [UserAmountViewModel] {
        return users
    }
    
    func totalAmountEditingEnd(totalAmount: Int?) {
        
        guard let transactionMode = transactionMode else { return }
        
        guard !users.isEmpty else { return }
        
        self.totalAmount = totalAmount
        guard let totalAmount = totalAmount else { return }
        
        self.view?.showTooltipCantExceedMax(with: false)
        
        if let viewMode = viewMode {
            switch viewMode {
            case .chargeMach:
                //Disable the confirm button in case the amount is greater than the amount the user can charge BCI
                if let maximum = users.first?.maximumAmount {
                    if totalAmount > maximum {
                        view?.disableConfirmationButton()
                        return
                    }
                }
            default:
                break
            }
        }
        
        switch transactionMode {
        case .request, .machRequest :
            //            guard totalAmount <= maximumTransactionAmount else {
            //                self.totalAmount = nil
            //                self.view?.clearTotalAmount()
            //                for user in users {
            //                    user.amount = 0
            //                }
            //                self.view?.setUserAmountLabel(amount: 0)
            //                self.view?.updateUsers()
            //                self.view?.disableConfirmationButton()
            //                self.view?.showTooltipCantExceedMax(with: true)
            //                return
            //            }
            if totalAmount == 0 {
                self.view?.disableConfirmationButton()
            } else {
                self.view?.enableConfirmationButton()
            }
            
        case .payment:
            guard isTotalAmountLessThanOrEqualToBalance(totalAmount: totalAmount) else {
                self.view?.showUnsufficientBalanceError()
                hideAmountErrorWithDelay()
                self.totalAmount = nil
                self.view?.clearTotalAmount()
                users[0].amount = 0
                self.view?.updateUsers()
                self.view?.disableConfirmationButton()
                return
            }
            self.view?.hideUnsufficientBalanceError()
            if totalAmount <= 0 {
                self.view?.disableConfirmationButton()
            } else {
                self.view?.enableConfirmationButton()
            }
        default:
            return
        }
        self.calculateSplit(users: users, totalAmount: totalAmount)
        self.view?.updateUsers()
    }
    
    private func calculateSplit(users: [UserAmountViewModel], totalAmount: Int) {
        let totalUsers = users.count + (self.splitCountingUser ? 1 : 0)
        let each = totalAmount / totalUsers
        for user in users {
            user.amount = each
        }
        self.userAmount = each
        self.view?.setUserAmountLabel(amount: each)
        if totalAmount > each * totalUsers {
            var rest = totalAmount - (each * totalUsers)
            var i = 1
            while rest > 0 {
                users[users.count - i].amount += 1
                rest -= 1
                i += 1
            }
        }
    }
    
    func setProfileImage() {
        guard let user = AccountManager.sharedInstance.getUser() else { return }
        let userViewModel = UserViewModel(user: user)
        self.view?.setImage(
            image: UserPhotoManager.sharedInstance.getProfileImage(),
            imageURL: userViewModel.profileImageUrl,
            placeholderImage: userViewModel.profileImage
        )
    }
    
    func setSplitCountingUser(splitCountingUser: Bool) {
        self.splitCountingUser = splitCountingUser
        showDivideTooltip()
    }
    
    func getUserAmount() -> Int {
        return self.userAmount
    }
    
    func totalAmountChanged(totalAmount: Int?) {
        if let amount = totalAmount {
            self.view?.updateTotalAmount(totalAmount: amount)
            
            if let viewMode = viewMode {
                switch viewMode {
                case .chargeMach:
                    //If the amount the user selected is smaller than the amount the user can charge BCI, show showTooltipCannotChargeMore. Otherwise, show showTooltipCannotChargeMore
                    if let maximum = users.first?.maximumAmount {
                        view?.showTooltipCannotChargeMore(with: !(amount > maximum))
                        view?.showTooltipCanChargeMore(with: amount > maximum)
                    } else {
                        if amount > maximumTransactionAmount {
                            view?.showExceededAmountError()
                            hideAmountErrorWithDelay()
                        }
                    }
                default:
                    break
                }
            }
        } else {
            self.view?.updateTotalAmount(totalAmount: 0)
        }
    }
    
    func individualAmountChanged(for index: IndexPath, amount: Int?) {
        // Implement for MDP.
    }
    
    func updateBalance() {
        repository?.getSavedBalance(response: {[weak self] (balance) in
            if let unwrappedBalance = balance, let unwrappedSelf = self {
                unwrappedSelf.balance = Int(unwrappedBalance.balance)
                unwrappedSelf.view?.updateBalance(balanceResponse: BalanceResponse(balance: unwrappedBalance.balance))
            }
        })
        self.repository?.getBalance(onSuccess: { (balanceResponse) in
            self.balance = Int(balanceResponse.balance)
            self.view?.updateBalance(balanceResponse: balanceResponse)
        }, onFailure: { (error) in
            self.handle(error: error)
        })
    }
    
    func getBalance() -> Int {
        return self.balance
    }
    
    func messageSet(message: String) {
        self.message = message
    }
    
    func transactionConfirmed() {
        guard transactionMode != nil else { return }
        self.view?.disableConfirmationButton()
        self.view?.presentPasscode(
            onSuccess: passcodeSucceeded,
            onFailure: passcodeFailed
        )
    }
    
    internal func passcodeSucceeded() {
        // Analytics
        guard let transactionMode = self.transactionMode else { return }
        if transactionMode.rawValue == "Cobro", self.users.count > 1 {
            self.view?.navigateToExecuteRequestTransaction()
        } else {
            self.view?.navigateToExecuteTransaction()
        }
    }
    
    internal func passcodeFailed() {
        // Analytics
        guard self.transactionMode != nil else { return }
    }
    
    func doneMessagePressed() {
        self.view?.hideInputMessageView()
    }
    
    func getMovementViewModel() -> MovementViewModel? {
        let totalAmount = self.totalAmount ?? 0
        guard let transactionMode = transactionMode else { return nil }
        switch transactionMode {
        case .payment:
            let paymentViewModel: PaymentViewModel = PaymentViewModel(userAmountViewModels: self.users, totalAmount: totalAmount, message: self.message, balance: self.balance)
            if (self.users.first?.isNear)! {
                paymentViewModel.metaData = TransactionMetadata(originatedBy: "bluetooth")
            }
            return paymentViewModel
        case .request, .machRequest:
            let requestViewModel: RequestViewModel = RequestViewModel(userAmountViewModels: self.users, totalAmount: totalAmount, message: self.message, balance: self.balance)
            if (self.users.first?.isNear)! {
                requestViewModel.metaData = TransactionMetadata(originatedBy: "bluetooth")
            }
            return requestViewModel
        default:
            return nil
        }
    }
    
    func setDefaultMessage(message: String) {
        self.message = message
        self.view?.updateMessage(text: message)
    }
    
    func backButtonPressed() {
        self.view?.navigateBack()
    }
    
    private func isTotalAmountLessThanOrEqualToBalance(totalAmount: Int) -> Bool {
        return totalAmount <= balance
    }
    
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError():
            self.view?.showNoInternetConnectionError()
        case .serverError(let selectAmountError):
            guard let selectAmountError = selectAmountError as? SelectAmountError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch selectAmountError {
            case .failed(_):
                break
            case .obtainedBalanceFailed(_):
                break
            }
        case .clientError(let selectAmountError):
            guard let selectAmountError = selectAmountError as? SelectAmountError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch selectAmountError {
            case .failed(_):
                break
            case .obtainedBalanceFailed:
                break
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
    
    private func hideAmountErrorWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {[unowned self] in
            self.view?.hideUnsufficientBalanceError()
        }
    }
    
    private func showDivideTooltip() {
        guard let mode = transactionMode,
            mode == .request else { return }
        //Logic: IF there are more than 2 users selected, or there's one user selected and the user added himself -> show tooltip
        let shouldShowSplitMoneyOption = self.users.count >= 2 || self.users.count == 1 && splitCountingUser ? false : true
        view?.showDivideTooltip(with: shouldShowSplitMoneyOption)
        view?.showAddUserToCharge(with: shouldShowSplitMoneyOption)
    }
}
