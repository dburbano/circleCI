//
//  TEFValidationDepositPresenter.swift
//  machApp
//
//  Created by Lukas Burns on 4/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class TEFValidationDepositPresenter: TEFValidationDepositPresenterProtocol {
    
    weak var view: TEFValidationDepositViewProtocol?
    var repository: TEFValidationDepositRepositoryProtocol?
    var selectedBank: Bank?
    var banks: [Bank] = []
    var accountNumber: String?
    weak var challengeDelegate: ChallengeDelegate?
    var process: ProcessResponse?
    
    required init(repository: TEFValidationDepositRepositoryProtocol?) {
        self.repository = repository
    }
    
    func setView(view: TEFValidationDepositViewProtocol) {
        self.view = view
    }
    
    func setChallenge(with banks: [Bank], process: ProcessResponse, delegate: ChallengeDelegate) {
        self.banks = banks
        self.challengeDelegate = delegate
        self.process = process
    }

    func viewDidLoad() {
        self.initializeBanks()
        guard let user = AccountManager.sharedInstance.getUser() else { return }
        let userViewModel = UserViewModel(user: user)
        let accountNumber = AccountManager.sharedInstance.getCashoutAccountNumber() ?? ""
        self.view?.set(name: "\(userViewModel.machFirstName) \(userViewModel.machLastName)")
        self.view?.set(rut: (AccountManager.sharedInstance.getRut()?.toRutFormat())!)
        self.accountNumber = accountNumber
        self.view?.set(accountNumber: accountNumber)
    }
    
    private func initializeBanks() {
        self.view?.reloadBanks()
        if let bankId = AccountManager.sharedInstance.getCashoutBank() {
            for (index, bank) in banks.enumerated() {
                if bank.identifier == bankId {
                    self.view?.setSelectedBank(at: index)
                    self.view?.set(bankName: bank.name)
                }
            }
        }
    }
    
    func bankSelected(at row: Int) {
        guard let bank = banks.get(at: row) else { return }
        self.selectedBank = bank
        self.view?.set(bankName: bank.name)
        validateFields()
    }
    
    func getBankName(at row: Int) -> String {
        guard let bank = banks.get(at: row) else { return ""}
        return bank.name
    }
    
    func getNumberOfBanks() -> Int {
        return banks.count
    }

    func accountNumberEdited(account: String?) {
        self.accountNumber = account
        self.validateFields()
    }

    internal func cleanAccountNumber(account: String) -> String {
        let cleanAccount = account.replacingOccurrences(
            of: "[^0-9 ]",
            with: "",
            options: NSString.CompareOptions.regularExpression, range: nil).trimmingCharacters(in: NSCharacterSet.whitespaces)

        return cleanAccount
    }

    private func validateFields() {
        guard self.selectedBank != nil else {
            self.view?.disableButton()
            return
        }

        guard let account = self.accountNumber, !account.isEmpty else {
            self.view?.disableButton()
            return
        }

        self.view?.enableButton()
    }

    internal func sendTEF(accountNumber: String) {
        let data = TEFVerification(bankId: (self.selectedBank?.identifier)!, bankAccount: accountNumber)
        self.repository?.createTEF(cashout: data, processId: self.process?.id ?? "", onSuccess: { (authenticationResponse) in
            self.challengeDelegate?.didSucceedChallenge(authenticationResponse: authenticationResponse)
        }, onFailure: { (apiError) in
            self.view?.enableButton()
            self.handle(error: apiError, showDefaultError: true)
        })
    }

    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let error):
            print(error)
        case .clientError(let error):
            guard let tefValidationDepositError = error as? TEFValidationDepositError else { return }
            switch tefValidationDepositError {
            case .tooManyTEFCreations, .tooManyCheckAttempts:
                self.view?.navigateToTooManyAttemptsDialogue()
            case .tooManyConsecutiveCreate:
                self.view?.navigateToTooManyConsecutiveCreateErrorDialogue()
            }
        case .processFailedError(let errorMessage):
            self.challengeDelegate?.didProcessFailed(errorMessage: errorMessage)
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }

}
