//
//  PrepaidCardMenuTablePresenter.swift
//  machApp
//
//  Created by Rodrigo Russell on 11/6/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class PrepaidCardMenuTablePresenter: PrepaidCardMenuTablePresenterProtocol {

    let faqRowNumber: Int = 0
    let removeCard: Int = 2

    weak var view: PrepaidCardMenuTableViewProtocol?
    var delegate: PrepaidCardHomeProtocol?

    func set(view: PrepaidCardMenuTableViewProtocol) {
        self.view = view
    }

    func set(delegate: PrepaidCardHomeProtocol?) {
        self.delegate = delegate
    }

    func tableViewDidSelectRow(indexOf: Int) {
        if indexOf == self.faqRowNumber {
            self.view?.showZendeskArticle()
        } else if indexOf == self.removeCard {
            self.delegate?.showRemovePrepaidCardDialogue()
        }
    }

}
