//
//  QuestionsResponse.swift
//  machApp
//
//  Created by lukas burns on 5/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct Question {

    var id: String
    var text: String
    var options: [QuestionOption] = []
}

extension Question: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.text = try unboxer.unbox(key: "text")
        self.options = try unboxer.unbox(key: "options")
    }
}
