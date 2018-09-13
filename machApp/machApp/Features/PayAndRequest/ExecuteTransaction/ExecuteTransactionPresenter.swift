//
//  ExecuteTransactionPresenter.swift
//  machApp
//
//  Created by lukas burns on 3/30/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

enum TransactionMode: String {
    case payment = "Pago"
    case request = "Cobro"
    case cashout = "Retiro"
    case machRequest = "Cobro a mach"
    case cashoutATM = "Recarga"
}

enum ViewMode {
    case chargeMach
    case deeplinkTransaction
    case normalTransaction
}

class ExecuteTransactionPresenter: ExecuteTransactionPresenterProtocol {

    weak var view: ExecuteTransactionViewProtocol?
    var repository: ExecuteTransactionRepositoryProtocol?
    var movementViewModel: MovementViewModel?
    var cashoutViewModel: CashoutViewModel?
    var cashoutATMViewModel: CashoutATMViewModel?
    var transactionMode: TransactionMode?
    var timer = Timer()

    let secondsBetweenLoadingMessages = 5.0

    required init(repository: ExecuteTransactionRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: ExecuteTransactionViewProtocol) {
        self.view = view
    }

    func setMovementViewModel(_ movementViewModel: MovementViewModel?) {
        self.movementViewModel = movementViewModel
    }

    func setCashoutViewModel(_ cashoutViewModel: CashoutViewModel?) {
        self.cashoutViewModel = cashoutViewModel
    }

    func setCashoutATMViewModel(_ cashoutATMViewModel: CashoutATMViewModel?) {
        self.cashoutATMViewModel = cashoutATMViewModel
    }

    func setTransactionMode(transactionMode: TransactionMode?) {
        self.transactionMode = transactionMode
        self.setUserInformation()
    }

    func setUserInformation() {
        guard let transactionMode = transactionMode else { return }
        switch transactionMode {
        case .request, .machRequest :
            self.view?.setAmount(amount: movementViewModel?.totalAmount ?? 0)
            self.view?.setUserImage(imageURL: movementViewModel?.userAmountViewModels.first?.profileImageUrl, placeHolder: movementViewModel?.userAmountViewModels.first?.profileImage)
            self.view?.setUserName(firstName: movementViewModel?.userAmountViewModels.first?.firstNameToShow ?? "", lastName: movementViewModel?.userAmountViewModels.first?.lastNameToShow ?? "")
            self.view?.showInitialRequestMessage()
        case .payment:
            self.view?.setAmount(amount: movementViewModel?.totalAmount ?? 0)
            self.view?.setUserImage(imageURL: movementViewModel?.userAmountViewModels.first?.profileImageUrl, placeHolder: movementViewModel?.userAmountViewModels.first?.profileImage)
            self.view?.setUserName(firstName: movementViewModel?.userAmountViewModels.first?.firstNameToShow ?? "", lastName: movementViewModel?.userAmountViewModels.first?.lastNameToShow ?? "")
            self.view?.showInitialPaymentMessage()
        case .cashout:
            self.view?.setAmount(amount: cashoutViewModel?.amount ?? 0)
            self.view?.setUserImage(imageURL: nil, placeHolder: #imageLiteral(resourceName: "badgeRetiroDineroMorado"))
            self.view?.setUserName(firstName:  "Monto a retirar", lastName: "")
            self.view?.showInitialCashoutMessage()
        case .cashoutATM:
            self.view?.setAmount(amount: cashoutATMViewModel?.amount ?? 0)
            self.view?.setUserImage(imageURL: nil, placeHolder: #imageLiteral(resourceName: "icWithdrawATM"))
            self.view?.setUserName(firstName: "Monto a retirar", lastName: "")
            self.view?.showInitialCashoutMessage()
        }
    }

    func executeTransaction() {
        TapticEngine.impact.prepare(TapticEngine.Impact.ImpactStyle.heavy)
        guard let transactionMode = self.transactionMode else {
            // handle this error
            return
        }

        switch transactionMode {
        case .payment:
            guard let movementViewModel = movementViewModel else {
                // handle this error
                return
            }
            executePayment(paymentViewModel: movementViewModel)
        case .request, .machRequest:
            guard let movementViewModel = movementViewModel else {
                // handle this error
                return
            }
            executeRequest(requestViewModel: movementViewModel)
        case .cashout:
            guard let cashoutViewModel = cashoutViewModel else {
                // handle this error
                return
            }
            executeCashOut(cashoutViewModel: cashoutViewModel)
        case .cashoutATM:
            guard let cashoutATMVieWModel = cashoutATMViewModel else {
                // handle this error
                return
            }
            executeCashoutATM(cashoutATMViewModel: cashoutATMVieWModel)
        }

    }

    func executePayment(paymentViewModel: MovementViewModel) {
        let phoneNumber = paymentViewModel.userAmountViewModels[0].user.phone?.cleanPhoneNumber()
        let machId = paymentViewModel.userAmountViewModels[0].user.machId
        var payment = Payment(toMachId: machId, toPhoneNumber: phoneNumber ?? "", message: paymentViewModel.message, amount: paymentViewModel.totalAmount)
        payment.metadata = paymentViewModel.metaData
        self.scheduleTimerToChangeLoadingMessage(each: secondsBetweenLoadingMessages)
        self.repository?.execute(payment: payment, onSuccess: { (transaction) in
            BranchIOManager.sharedInstance.userCompletedActionWith(campaignEvent: .createPayment)
            self.stopTimerForMessages()
            self.view?.showSuccessPaymentMessage()
            self.handleExecutionSuccessfull(transaction: transaction)
            //The tabBar tooltip should be hidden once the user finishes a request or a payment
            ConfigurationManager.sharedInstance.didShowTabBarTooltip()
        }, onFailure: { (error) in
            self.stopTimerForMessages()
            self.handle(error: error)
        })
    }

    func executeRequest(requestViewModel: MovementViewModel) {
        guard let transactionMode = transactionMode else { return }
        var requests: [RequestPayment] = []

        for request in requestViewModel.userAmountViewModels {
            requests.append(RequestPayment(
                fromMachId: request.user.machId,
                fromPhoneNumber: request.user.phone?.cleanPhoneNumber() ?? "",
                message: requestViewModel.message,
                amount: request.amount,
                metadata: requestViewModel.metaData
            ))
        }

        switch transactionMode {
        case .request:
            executeDefaultRequestWith(requestViewModel: requestViewModel, request: requests)
        case .machRequest:
            executeMachRequestWith(requestViewModel: requestViewModel, request: requests[0])
        default:
            break
        }
    }

    func executeCashOut(cashoutViewModel: CashoutViewModel) {
        let cashout = Cashout(bankId: cashoutViewModel.bank.identifier, amount: cashoutViewModel.amount, accountNumber: cashoutViewModel.accountNumber)
        self.repository?.execute(cashout: cashout, onSuccess: { (transaction) in
            BranchIOManager.sharedInstance.userCompletedActionWith(campaignEvent: .cashoutCompleted)
            self.view?.showSuccessCashoutMessage()
            self.saveUserCashoutInformation()
            if AlamofireNetworkLayer.sharedInstance.isInContingency {
                self.handleExecutionSuccessInContingency()
            } else {
                self.handleExecutionSuccessfull(transaction: transaction)
            }
            NotificationCenter.default.post(name: .DidSaveAccount, object: nil)
        }, onFailure: { (error) in
            self.handle(error: error)
        })
    }

    private func saveWithdrawATMDetail(cashoutATMResponse: CashoutATMResponse) {
        let cashoutATM = CashoutATMModel(cashout: cashoutATMResponse)
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                realm.add(cashoutATM, update: true)
            }
        } catch { }
    }

    func executeCashoutATM(cashoutATMViewModel: CashoutATMViewModel) {
        let cashoutATM = CashoutATM(amount: cashoutATMViewModel.amount)
        self.repository?.execute(cashoutATM: cashoutATM, onSuccess: { (cashoutATMResponse) in
            self.saveWithdrawATMDetail(cashoutATMResponse: cashoutATMResponse)
            AccountManager.sharedInstance.set(hideWithdrawATMcreatedMessage: false)
            self.view?.navigateToCashoutATMDetail(with: cashoutATMResponse)
        }, onFailure: { (error) in
            self.handle(error: error)
        })
    }

    func handleExecutionSuccessfull(transaction: Transaction?) {
        self.updateAnimations()
        TapticEngine.notification.feedback(.success)
        if let transaction = transaction {
            transaction.seen = true
            self.repository?.saveTransaction(transaction: transaction)
        }
        Thread.runOnMainQueue(1.5, completion: {
            if let transaction = transaction {
                let transactionViewModel = TransactionViewModel(transaction: transaction)
                self.view?.navigateToChatDetail(with: transactionViewModel)
            } else {
                self.view?.navigateToChatDetail(with: nil)
            }
        })
    }
    
    func handleExecutionSuccessInContingency() {
        self.updateAnimations()
        TapticEngine.notification.feedback(.success)
        Thread.runOnMainQueue(1.5) {
            self.view?.closeView()
        }
    }

    func saveUserCashoutInformation() {
        guard let cashoutVM = cashoutViewModel else { return }
        AccountManager.sharedInstance.set(cashoutBank: cashoutVM.bank.identifier)
        AccountManager.sharedInstance.set(cashoutAccountNumber: cashoutVM.accountNumber)
        AccountManager.sharedInstance.set(cashoutBankName: cashoutVM.bank.name)
    }

    private func executeMachRequestWith(requestViewModel: MovementViewModel, request: RequestPayment) {
        self.repository?.executeMach(request: request, onSuccess: {[weak self] (transaction) in
            BranchIOManager.sharedInstance.userCompletedActionWith(campaignEvent: .createRequest)
            ConfigurationManager.sharedInstance.didCompleteCharge()
            self?.view?.showSuccessRequestMessage()
            self?.handleExecutionSuccessfull(transaction: transaction)
            }, onFailure: {[weak self] error in
                self?.handle(error: error)
        })
    }

    private func executeDefaultRequestWith(requestViewModel: MovementViewModel, request: [RequestPayment]) {
        self.repository?.execute(request: request, onSuccess: { (transactions) in
            BranchIOManager.sharedInstance.userCompletedActionWith(campaignEvent: .createRequest)
            //The tabBar tooltip should be hidden once the user finishes a request or a payment, different to mach team.
            ConfigurationManager.sharedInstance.didShowTabBarTooltip()
            self.view?.showSuccessRequestMessage()
            guard let transaction = transactions?.first else {
                self.closeView()
                return
            }
            self.handleExecutionSuccessfull(transaction: transaction)
        }, onFailure: { (error) in
            self.handle(error: error)
        })
    }
    
    private func updateAnimations() {
        view?.hideSpinner()
        view?.playCheckAnimation()
    }

    private func closeView(after seconds: Double = 1.5) {
        Thread.runOnMainQueue(seconds) {
            self.view?.closeView()
        }
    }

    //swiftlint:disable:next cyclomatic_complexity
    private func handle(error apiError: ApiError) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
            self.closeView()
        case .serverError(let executeTransactionError):
            guard let executeTransactionError = executeTransactionError as? ExecuteTransactionError else { return }
            guard let transactionMode = self.transactionMode else { return }
            switch transactionMode {
            case .payment:
                self.handlePaymentError(executeTransactionError: executeTransactionError)
            case .request, .machRequest :
                self.handleRequestError(executeTransactionError: executeTransactionError)
            case .cashout:
                self.handleCashoutError(executeTransactionError: executeTransactionError)
            case .cashoutATM:
                self.handleCashoutATMError(executeTransactionError: executeTransactionError)
            }
        case .clientError(let executeTransactionError):
            guard let executeTransactionError = executeTransactionError as? ExecuteTransactionError else { return }
            guard let transactionMode = self.transactionMode else { return }
            switch transactionMode {
            case .payment:
                self.handlePaymentError(executeTransactionError: executeTransactionError)
            case .request, .machRequest :
                self.handleRequestError(executeTransactionError: executeTransactionError)
            case .cashout:
                self.handleCashoutError(executeTransactionError: executeTransactionError)
            case .cashoutATM:
                self.handleCashoutATMError(executeTransactionError: executeTransactionError)
            }
        case .smyteError(let message):
            view?.showBlockedAction(with: message)
            self.closeView()
        default:
            guard let transactionMode = self.transactionMode else { return }
            switch transactionMode {
            case .payment:
                self.view?.showPaymentError()
            case .cashoutATM:
                self.view?.navigateToSelectAmountCashoutATM(with: apiError)
            default:
                break
            }
            self.closeView()
        }
    }

    private func handlePaymentError(executeTransactionError: ExecuteTransactionError) {
        switch executeTransactionError {
        case .paymentFailed( _):
            self.view?.showFailedPaymentMessage()
        default:
            self.view?.showPaymentError()
        }
        self.closeView()
    }

    private func handleRequestError(executeTransactionError: ExecuteTransactionError) {
        switch executeTransactionError {
        case .requestFailed( _):
            self.view?.showFailedRequestMessage()
        default:
            self.view?.showServerError()
        }
        self.closeView()
    }

    private func handleCashoutError(executeTransactionError: ExecuteTransactionError) {
        switch executeTransactionError {
        case .cashoutUnknownState( _):
            self.saveUserCashoutInformation()
            self.view?.navigateToHome(with: executeTransactionError)
        case .invalidAccountNumber:
            self.view?.navigateToWithdraw(with: executeTransactionError)
        default:
            self.view?.showFailedCashoutMessage()
            self.closeView()
        }
    }

    private func handleCashoutATMError(executeTransactionError: ExecuteTransactionError) {
        switch executeTransactionError {
        case .cashoutUnknownState( _):
            self.view?.navigateToSelectAmountCashoutATM(with: executeTransactionError)
        case .cashoutMaxAttempts:
            self.view?.navigateToSelectAmountCashoutATM(with: executeTransactionError)
        case .cashoutATMDailyMaxAttempts:
            self.view?.navigateToSelectAmountCashoutATM(with: executeTransactionError)
        default:
            self.view?.showFailedCashoutMessage()
        }
    }

    @objc private func changeLoadingMessage() {
        let loadingMessage = getRandomLoadingMessage()
        self.view?.setLoadingMessage(message: loadingMessage)
    }

    private func getRandomLoadingMessage() -> String {
        let amountOfLoadingMessages = Constants.ExecuteTransaction.paymentLoadingMessages.count
        let randomNumber = Int(arc4random_uniform((UInt32(amountOfLoadingMessages))))
        let randomMessage = Constants.ExecuteTransaction.paymentLoadingMessages[randomNumber]
        return randomMessage
    }

    private func scheduleTimerToChangeLoadingMessage(each seconds: Double) {
        timer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(changeLoadingMessage), userInfo: nil, repeats: true)
    }

    private func stopTimerForMessages() {
        timer.invalidate()
    }
}
