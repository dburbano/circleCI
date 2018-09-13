//
//  RecoverAccount.swift
//  machApp
//
//  Created by lukas burns on 5/25/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct SecurityQuestionsDataTransfer {
    var requestId: String?
    var questionsId: String?
    var answers: [Answer]

    public init (requestId: String?, questionsId: String?, answers: [Answer] ) {
        self.questionsId = questionsId
        self.requestId = requestId
        self.answers = answers
    }
}

extension SecurityQuestionsDataTransfer: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "questionsId" {
            return "questions_id"
        }
        if propertyName == "requestId" {
            return "request_id"
        }
        return propertyName
    }

    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
