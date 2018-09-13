//
//  PrepaidCardMenuTableContract.swift
//  machApp
//
//  Created by Rodrigo Russell on 11/6/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol PrepaidCardMenuTableViewProtocol: BaseViewProtocol {
    func showZendeskArticle()
}

protocol PrepaidCardMenuTablePresenterProtocol: BasePresenterProtocol {
    func set(view: PrepaidCardMenuTableViewProtocol)
    func set(delegate: PrepaidCardHomeProtocol?)
    func tableViewDidSelectRow(indexOf: Int)
}

enum PrepaidCardMenuTableError {
    
}

class PrepaidCardMenuTableErrorParser: ErrorParser {
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
