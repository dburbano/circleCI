//
//  RecoverAccountResponse.swift
//  machApp
//
//  Created by lukas burns on 5/25/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

enum QuestionProvider: String {
    case equifax
    case mach
}

public struct SecurityQuestionsVerificationResponse {
    var requestId: String?
    var questionsId: String?
    var questions: [Question] = []
    var provider: QuestionProvider?
}

extension SecurityQuestionsVerificationResponse: Unboxable {

    public init(unboxer: Unboxer) throws {
        self.requestId = unboxer.unbox(key: "request_id")
        self.questionsId = unboxer.unbox(key: "questions_id")
        self.questions = try unboxer.unbox(key: "questions")
        let providerString: String? = unboxer.unbox(key: "provider")
        if let providerString = providerString {
            self.provider =  QuestionProvider(rawValue: providerString)
        }
    }

    public static func create(from dictionary: JSON) throws -> SecurityQuestionsVerificationResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: SecurityQuestionsVerificationResponse = try unbox(dictionary: dictionaryObject)
        return response
    }

}
