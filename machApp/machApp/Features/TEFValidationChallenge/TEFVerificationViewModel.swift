//
//  TEFVerificationViewModel.swift
//  machApp
//
//  Created by Lukas Burns on 4/18/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

enum TEFVerificationStatus: String {
    case inProgress = "IN PROGRESS"
    case verified = "VERIFIED"
    case rejected = "REJECTED"
    case expired = "EXPIRED"
    case invalid = "INVALID"
}

class TEFVerificationViewModel {
    
    var tefVerificationId: String
    var bankId: String?
    var bankAccount: String?
    var status: TEFVerificationStatus
    
    init (tefVerificationResponse: TEFVerificationResponse) {
        self.tefVerificationId = tefVerificationResponse.tefVerificationId
        self.bankId = tefVerificationResponse.bankId
        self.bankAccount = tefVerificationResponse.bankAccount
        self.status = TEFVerificationStatus(rawValue: tefVerificationResponse.status) ?? TEFVerificationStatus.expired
    }

}
