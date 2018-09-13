//
//  QuestionOptionResponse.swift
//  machApp
//
//  Created by lukas burns on 5/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct QuestionOption {

    var id: String
    var text: String
}

extension QuestionOption: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.text = try unboxer.unbox(key: "text")
    }
}
