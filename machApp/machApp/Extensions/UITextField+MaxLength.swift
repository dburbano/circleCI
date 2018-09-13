//
//  UITextField+MaxLength.swift
//  machApp
//
//  Created by Rodrigo Russell on 2/5/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import UIKit

private var maxLengths = [UITextField: Int]()

extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            if l == 0 {
                return 150
            }
            return l
        }
        set {
            maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
}

extension String
{
    func safelyLimitedTo(length n: Int) -> String {
        if (self.count <= n) {
            return self
        }
        return String(Array(self).prefix(upTo: n))
    }
}
