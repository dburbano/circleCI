//
//  UIButton+Mach.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func drawBottomBorder(with color: UIColor) {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.bounds.size.width, height: self.frame.size.height)

        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }

    func addDashedBorder() {
        let dashedBorderMask = CAShapeLayer()
        dashedBorderMask.strokeColor = UIColor(gray: 0.6, alpha: 1.0).cgColor
        dashedBorderMask.lineDashPattern = [1.5, 1.5]
        dashedBorderMask.frame = bounds
        dashedBorderMask.fillColor = UIColor.clear.cgColor
        dashedBorderMask.path = UIBezierPath(roundedRect: bounds, cornerRadius: 29.0).cgPath
        layer.addSublayer(dashedBorderMask)
    }
}

private let minimumHitArea = CGSize(width: 100, height: 100)

extension UIButton {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if the button is hidden/disabled/transparent it can't be hit
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }

        // increase the hit frame to be at least as big as `minimumHitArea`
        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
        let largerFrame = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)

        // perform hit test on larger frame
        return (largerFrame.contains(point)) ? self : nil
    }
}
