//
//  GeneratePrepaidCardPresenter.swift
//  machApp
//
//  Created by Lukas Burns on 4/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class GeneratePrepaidCardPresenter: GeneratePrepaidCardPresenterProtocol {

    weak var view: GeneratePrepaidCardViewProtocol?
    var repository: GeneratePrepaidCardRepositoryProtocol?
    
    var isTermsAndConditionsAccepted: Bool = false {
        didSet {
            self.updateViewForTermsAndConditionsStatus()
        }
    }
    
    required init(repository: GeneratePrepaidCardRepositoryProtocol?) {
        self.repository = repository
        self.isTermsAndConditionsAccepted = false
    }
    
    func setView(view: GeneratePrepaidCardViewProtocol) {
        self.view = view
    }
    
    func generateCard() {
        self.view?.setGenerateButtonAsLoading()
        self.repository?.generatePrepaidCard(onSuccess: {
            // Success
            self.view?.setGenerateButtonAsActive()
        }, onFailure: { (apiError) in
            // Error
            self.view?.setGenerateButtonAsActive()
        })
        self.view?.navigateToGeneratingPrepaidCard()
    }
    
    func seeTermsAndConditions() {
        
    }
    
    func termsAndConditionsCheckboxPressed() {
        self.isTermsAndConditionsAccepted = !self.isTermsAndConditionsAccepted
        self.updateViewForTermsAndConditionsStatus()
    }
    
    private func updateViewForTermsAndConditionsStatus() {
        if self.isTermsAndConditionsAccepted {
            self.setViewWithTermsAndConditionsAccepted()
        } else {
            self.setViewWithTermsAndConditionsRejected()
        }
    }
    
    private func setViewWithTermsAndConditionsAccepted() {
        self.view?.setCheckboxAsSelected()
        self.view?.setGenerateButtonAsActive()
    }
    
    private func setViewWithTermsAndConditionsRejected() {
        self.view?.setCheckboxAsUnselected()
        self.view?.setGenerateButtonAsDisabled()
    }
    
}
