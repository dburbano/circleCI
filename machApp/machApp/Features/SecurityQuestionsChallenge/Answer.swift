//
//  Answer.swift
//  machApp
//
//  Created by lukas burns on 5/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap

public struct Answer {
    var questionId: String?
    var answerId: String?

    public init (questionId: String?, answerId: String?) {
        self.questionId = questionId
        self.answerId = answerId
    }
}

extension Answer: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "questionId" {
            return "question_id"
        }
        if propertyName == "answerId" {
            return "answer_id"
        }
        return propertyName
    }

    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}
