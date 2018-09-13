//
//  DeviceLayoutConstraints.swift
//  machApp
//
//  Created by lukas burns on 11/9/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable identifier_name
@IBDesignable
class DeviceLayoutConstraint: NSLayoutConstraint {

    @IBInspectable var iphone4: CGFloat = 0.0 { didSet { updateConstant(size: .screen3_5Inch, constant: iphone4)}}
    @IBInspectable var iphone5: CGFloat = 0.0 { didSet { updateConstant(size: .screen4Inch, constant: iphone5)}}
    @IBInspectable var iphone6: CGFloat = 0.0 { didSet { updateConstant(size: .screen4_7Inch, constant: iphone6)}}
    @IBInspectable var iphone6Plus: CGFloat = 0.0 { didSet { updateConstant(size: .screen5_5Inch, constant: iphone6Plus)}}
    @IBInspectable var iphoneX: CGFloat = 0.0 { didSet { updateConstant(size: .screen5_8Inch, constant: iphoneX)}}
    @IBInspectable var inch7_9: CGFloat = 0.0 { didSet { updateConstant(size: .screen7_9Inch, constant: inch7_9)}}
    @IBInspectable var inch9_7: CGFloat = 0.0 { didSet { updateConstant(size: .screen9_7Inch, constant: inch9_7)}}
    @IBInspectable var inch12_9: CGFloat = 0.0 { didSet { updateConstant(size: .screen12_9Inch, constant: inch12_9)}}
 
    fileprivate func updateConstant(size: Size, constant: CGFloat) {
        if size == deviceSize() {
            self.constant = constant
            layoutIfNeeded()
        }
    }

    open func deviceSize() -> Size {
        return UIDevice().size()
    }

    @objc open func layoutIfNeeded() {
        self.firstItem?.layoutIfNeeded()
        self.secondItem?.layoutIfNeeded()
    }
}
