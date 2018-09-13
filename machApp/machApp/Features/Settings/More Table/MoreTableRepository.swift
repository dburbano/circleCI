//
//  MoreTableRepository.swift
//  machApp
//
//  Created by Rodrigo Russell on 12/19/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

//  Created by Lukas Burns on 12/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class MoreTableRepository: MoreTableRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: MoreTableErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: MoreTableErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func getUseTouchId() -> Bool {
        return AccountManager.sharedInstance.getUseTouchId()
    }
    
    func setUseTouchId(isOn: Bool) {
        AccountManager.sharedInstance.set(useTouchId: isOn)
    }

}
