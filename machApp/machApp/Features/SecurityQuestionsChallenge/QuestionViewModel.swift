//
//  QuestionViewModel.swift
//  machApp
//
//  Created by lukas burns on 5/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class QuestionViewModel {

    var text: String?
    var options: [QuestionOptionViewModel] = []
    var id: String?
    var provider: QuestionProvider?

    convenience init(question: Question, provider: QuestionProvider?) {
        self.init()
        self.text = question.text
        self.id = question.id
        self.options = question.options.map({ (questionOption) -> QuestionOptionViewModel in
            return QuestionOptionViewModel(questionOption: questionOption)
        })
        self.provider = provider
    }

    func getSelectedOption() -> QuestionOptionViewModel? {
        for option in options {
            if option.isSelected {
                return option
            }
        }
        return nil
    }
}
