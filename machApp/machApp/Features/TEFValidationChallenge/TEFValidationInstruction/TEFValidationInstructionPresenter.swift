//
//  TEFValidationInstructionPresenter.swift
//  machApp
//
//  Created by Lukas Burns on 4/10/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class TEFValidationInstructionPresenter: TEFValidationInstructionPresenterProtocol {
    
    weak var view: TEFValidationInstructionViewProtocol?
    var repository: TEFValidationInstructionRepositoryProtocol?

    required init(repository: TEFValidationInstructionRepositoryProtocol?) {
        self.repository = repository
    }
    
    var areInstructionsUnderstood: Bool = false {
        didSet {
            self.updateViewForunderstandInstructionStatus()
        }
    }
    
    func setView(view: TEFValidationInstructionViewProtocol) {
        self.view = view
    }

    func setup() {
        if self.areInstructionsUnderstood {
            self.view?.setStartButtonAsActive()
        } else {
            self.view?.setStartButtonAsDisabled()
        }
    }

    func understandInstructionCheckboxPressed() {
        self.areInstructionsUnderstood = !self.areInstructionsUnderstood
        self.updateViewForunderstandInstructionStatus()
    }
    
    private func updateViewForunderstandInstructionStatus() {
        if self.areInstructionsUnderstood {
            self.setViewWithUnderstandInstructionAccepted()
        } else {
            self.setViewWithUnderstandInstructionRejected()
        }
    }
    
    private func setViewWithUnderstandInstructionAccepted() {
        self.view?.setCheckboxAsSelected()
        self.view?.setStartButtonAsActive()
    }
    
    private func setViewWithUnderstandInstructionRejected() {
        self.view?.setCheckboxAsUnselected()
        self.view?.setStartButtonAsDisabled()
    }

    internal func getLastTEFValidation() {
        self.view?.setStartButtonAsLoading()
        self.repository?.getLastTEFValidation(onSuccess: { (response) in
            let tefVerificationViewModel = TEFVerificationViewModel(tefVerificationResponse: response)
            self.view?.setStartButtonAsDisabled()
            switch tefVerificationViewModel.status {
            case .inProgress:
                self.view?.navigateToTEFValidationAmount(tefVerificationViewModel: tefVerificationViewModel)
            case .verified, .rejected, .expired, .invalid:
                self.view?.navigateToTEFValidationDeposit()
            }
        }, onFailure: { (apiError) in
            self.view?.setStartButtonAsActive()
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
            guard let tefValidationError = error as? TEFValidationInstructionError else { return }
            switch tefValidationError {
            case .noTefVerificationFound(_):
                self.view?.navigateToTEFValidationDeposit()
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
}
