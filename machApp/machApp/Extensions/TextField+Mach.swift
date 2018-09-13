//
//  TextField+Mach.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/20/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func drawBottomBorder() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = Color.pinkishGrey.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.bounds.size.width, height: self.frame.size.height)

        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }

    func drawBottomBorder(borderWidth: CGFloat, color: UIColor) -> CALayer {
        let border = CALayer()
        let width = CGFloat(borderWidth)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.w, height: self.h)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        return border
    }

    func drawErrorBottomBorder() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = Color.redOrange.cgColor
        border.frame = CGRect(x: 0, y: self.frame.height - width, width:  self.frame.width, height: self.frame.height)

        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
