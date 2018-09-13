//
//  MoreFirstTypeCell.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 9/11/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

public struct MoreCellModel {

    var iconName: String
    var titleText: String
    var booleanAttribute: Bool?

    init(iconName: String, titleText: String) {
        self.iconName = iconName
        self.titleText = titleText
    }

    init(iconName: String, titleText: String, booleanAttribute: Bool) {
        self.init(iconName: iconName, titleText: titleText)
        self.booleanAttribute = booleanAttribute
    }

    mutating func setBooleanAttributeWith(state: Bool) {
        booleanAttribute = state
    }
}
