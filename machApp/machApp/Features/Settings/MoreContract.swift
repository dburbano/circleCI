//
//  MoreContract.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/18/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

protocol MoreViewProtocol: BaseViewProtocol {
    func navigateToRegister()
    func navigateToProfile()
    func setUserName(userName: String?)
    func setEmail(email: String?)
    func setImage(image: UIImage?, imageURL: URL?, placeholderImage: UIImage?)
    func showValidatedMail(with image: UIImage)
}

protocol MorePresenterProtocol: BasePresenterProtocol {
    func setView(view: MoreViewProtocol)
    func profileButtonTapped()
    func setUserInfo()
    func isUsersMailValidated()
}

protocol MoreRepositoryProtocol {
     func isUsersMailValidated(response: (Bool) -> Void)
}

enum MoreError: Error {
    case failed(message: String)
}

class MoreErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
