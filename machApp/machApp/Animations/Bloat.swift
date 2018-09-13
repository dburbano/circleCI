//
//  Bloat.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

extension UILabel {
    func bloat() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(value: 0.9)
        animation.duration = 0.3
        animation.repeatCount = 4.0
        animation.autoreverses = true
        self.layer.add(animation, forKey: nil)
    }
}

extension UIButton {
    func bloatOnce() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(value: 0.9)
        animation.duration = 0.1
        animation.repeatCount = 1.0
        animation.autoreverses = true
        self.layer.add(animation, forKey: nil)
    }

    func bloat() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(value: 0.9)
        animation.duration = 0.3
        animation.repeatCount = 4.0
        animation.autoreverses = true
        self.layer.add(animation, forKey: nil)
    }
}
