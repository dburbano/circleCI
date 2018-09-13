//
//  Theme.swift
//  machApp
//
//  Created by lukas burns on 4/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class Theme {
    static func applyTheme() {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.clear
    }

}
