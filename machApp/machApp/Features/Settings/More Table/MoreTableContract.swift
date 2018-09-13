//
//  MoreTableContract.swift
//  machApp
//
//  Created by lukas burns on 9/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

protocol MoreTableViewProtocol: class {
    func navigateToCashOut()
    func inviteFriends(withString string: String, url: URL, excludedTypes: [UIActivityType])
    func navigateToChangePIN()
    func navigateToHelp()
    func navigateToLegal()
    func navigateToHistory()
    func presentPasscode(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void)
}

protocol MoreTablePresenterProtocol {
    var view: MoreTableViewProtocol? { get set }
    func handleDidSelectRowAt(indexPath: IndexPath)
    func setUseTouchId(isOn: Bool)
    func getUseTouchId() -> Bool
    func presentShare()
    func trackNavigateToHistory()
}

protocol MoreTableRepositoryProtocol {
    func getUseTouchId() -> Bool
    func setUseTouchId(isOn: Bool)
}

enum MoreTableError: Error {
    case failed(message: String)
}

class MoreTableErrorParser: ErrorParser {
    
    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
