//
//  QuestionOptionViewModel.swift
//  machApp
//
//  Created by lukas burns on 5/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class QuestionOptionViewModel {

    var id: String?
    var text: String?
    var isSelected: Bool = false
    var questionOption: QuestionOption?

    convenience init(questionOption: QuestionOption) {
        self.init()
        self.id = questionOption.id
        self.text = questionOption.text
        self.questionOption = questionOption
    }
}
