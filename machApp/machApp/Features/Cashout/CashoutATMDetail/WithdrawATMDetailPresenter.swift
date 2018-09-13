//
//  WithdrawATMDetailPresenter.swift
//  machApp
//
//  Created by Lukas Burns on 1/2/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class WithdrawATMDetailPresenter: WithdrawATMDetailPresenterProtocol {

    weak var view: WithdrawATMDetailViewProtocol?
    var repository: WithdrawATMDetailRepositoryProtocol?
    var cashoutATMResponse: CashoutATMResponse?
    var countdown = 0
    var time: Timer?

    required init(repository: WithdrawATMDetailRepositoryProtocol?) {
        self.repository = repository
    }

    // MARK: WithdrawPresenterProtocol
    func setView(view: WithdrawATMDetailViewProtocol) {
        self.view = view
    }

    private func calculatedTimer(endDate: Date) {
        let startDate = Date()
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: startDate, to: endDate)

        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0

        self.countdown = (hour * 3600) + (minute * 60) + second
    }

    private func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60

        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }

    @objc private func updateTimer() {
        if self.countdown < 1 {
            // it expires while user is seeing the view
            self.view?.setDisabledDetailArea(expired: true)
        } else {
            self.countdown -= 1
            self.view?.setExpiredAtLabel(expiredAt: self.timeString(time: TimeInterval(self.countdown)))
        }
    }

    func initialSetup(_ cashoutATMResponse: CashoutATMResponse?) {
        self.getBalanceAndUpdate()
        self.cashoutATMResponse = cashoutATMResponse
        self.view?.setCodeLabel(code: cashoutATMResponse?.nigCode ?? "")
        self.view?.setAmountLabel(amount: cashoutATMResponse?.amount ?? 0)

        self.calculatedTimer(endDate:  (cashoutATMResponse?.expiresAt ?? nil)!)
        if time == nil {
            time = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        }
        self.view?.setExpiredAtLabel(expiredAt: self.timeString(time: TimeInterval(self.countdown)))
    }

    func getBalanceAndUpdate() {
        if let balance = BalanceManager.sharedInstance.getBalance()?.balance {
            self.view?.updateBalance(balance: Int(balance))
        }
        self.repository?.getBalance(onSuccess: { (balanceResponse) in
            self.view?.updateBalance(balance: Int(balanceResponse.balance))
        }, onFailure: { (error) in
            self.handle(error: error)
        })
    }

    //swiftlint:disable:next
    private func handle(error apiError: ApiError) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let withdrawError):
            guard let withdrawError = withdrawError as? WithdrawATMDetailError else { return }
            self.view?.showServerError()
            switch withdrawError {
            case .balance:
                break
            }
        case .clientError(let withdrawError):
            guard let withdrawError = withdrawError as? WithdrawATMDetailError else { return }
            self.view?.showServerError()
            switch withdrawError {
            case .balance:
                break
            }
        default:
            self.view?.showServerError()
        }
    }

    func getPin() -> String {
        return self.cashoutATMResponse?.pin ?? ""
    }

    func saveWithdrawATMDetail(cashoutATMResponse: CashoutATMResponse) {
        let cashoutATM = CashoutATMModel(cashout: cashoutATMResponse)
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                realm.add(cashoutATM, update: true)
            }
        } catch { }
    }

    func getWithdrawATMDetail() -> CashoutATMModel? {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            return realm.objects(CashoutATMModel.self).first
        } catch {
            return nil
        }
    }

    func showDialogueWhenWithdrawWasCreated() {
        if !AccountManager.sharedInstance.getHideWithdrawATMCreatedMessage() {
            AccountManager.sharedInstance.set(hideWithdrawATMcreatedMessage: true)
            Thread.runOnMainQueue(0.5, completion: { 
                self.view?.goToCashoutATMCreatedDialogue()
            })
        }
    }
}
