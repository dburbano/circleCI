//
//  LegalPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 7/31/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class LegalPresenter: LegalPresenterProtocol {

    weak var view: LegalViewProtocol?
    var repository: LegalRepositoryProtocol?

    required init(repository: LegalRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: LegalViewProtocol) {
        self.view = view
    }

    func navigateBackTapped() {
        view?.navigateBack()
    }
}
