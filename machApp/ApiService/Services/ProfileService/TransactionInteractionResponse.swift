//
//  TransactionInteractionResponse.swift
//  machApp
//
//  Created by lukas burns on 11/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct TransactionInteractionResponse {
    let interactionId: String?
    let date: Date?
    let type: String?
    let availableAt: Date?
    let triesRemaining: Int?
    let reactedBy: String?

}

extension TransactionInteractionResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.interactionId = unboxer.unbox(key: "id")
        self.date =  Date().dateFromISOString(isoDateString: unboxer.unbox(key: "date") ?? "")
        self.type = unboxer.unbox(key: "type")
        self.availableAt = Date().dateFromISOString(isoDateString: unboxer.unbox(key: "availableAt") ?? "")
        self.triesRemaining = unboxer.unbox(key: "triesRemaining")
        self.reactedBy = unboxer.unbox(key: "reactedBy")
    }
}
