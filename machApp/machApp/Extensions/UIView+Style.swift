//
//  UIView+Corners.swift
//  machApp
//
//  Created by lukas burns on 4/18/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

enum GradientStyle {
    case primary
    case secondary
}

extension UIView {

    private struct AssociatedKeys {
        static var gradientLayer: CAGradientLayer?
        static var shadowLayer: CAShapeLayer?
    }

    public var gradientLayer: CAGradientLayer? {
        get {
            if let gradientLayer = objc_getAssociatedObject(self, &AssociatedKeys.gradientLayer) as? CAGradientLayer {
                return gradientLayer
            }
            return nil
        }
        set (newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.gradientLayer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var shadowLayer: CAShapeLayer? {
        get {
            if let shadowLayer = objc_getAssociatedObject(self, &AssociatedKeys.shadowLayer) as? CAShapeLayer {
                return shadowLayer
            }
            return nil
        }
        set (newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.shadowLayer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func setMachGradient(includesStatusBar: Bool = true, navigationBar: UINavigationBar? = nil, withRoundedBottomCorners: Bool = true, withShadow: Bool = true, gradientStyle: GradientStyle = .primary) {

        self.backgroundColor = UIColor.clear
        self.clipsToBounds = false

        var heightSum: CGFloat = includesStatusBar ? UIApplication.shared.statusBarFrame.h : 0.0
        if let navigationBar = navigationBar {
            heightSum += navigationBar.h
        }
        let yOffset = heightSum
        heightSum += self.h

        if self.gradientLayer != nil {
            self.gradientLayer?.removeFromSuperlayer()
        }
        gradientLayer = CAGradientLayer()
        guard let gradientLayer = gradientLayer else { return }
        gradientLayer.frame = CGRect(x: 0, y: -1 * yOffset, width: self.w, height: heightSum + yOffset)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        switch gradientStyle {
        case .primary:
             gradientLayer.colors = [Color.violetBlue.cgColor, Color.dodgerBlue.cgColor]
        case .secondary:
             gradientLayer.colors = [Color.dodgerBlue.cgColor, Color.blurple.cgColor]
        }
        let bezierPath = UIBezierPath(roundedRect: gradientLayer.frame, byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight], cornerRadii: CGSize(width: 15.0, height: 15.0)).cgPath

        if withRoundedBottomCorners {
            let maskLayer = CAShapeLayer()
            maskLayer.path = bezierPath
            gradientLayer.backgroundColor = UIColor.white.cgColor
            gradientLayer.mask = maskLayer

        }
        self.layer.insertSublayer(gradientLayer, at: 0)

        if self.shadowLayer != nil {
            self.shadowLayer?.removeFromSuperlayer()
        }

        if withShadow {
            shadowLayer = CAShapeLayer()
            guard let shadowLayer = shadowLayer else { return }
            shadowLayer.frame = gradientLayer.frame
            shadowLayer.shadowPath = bezierPath
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 5
            shadowLayer.masksToBounds = false
            shadowLayer.shadowOffset = .zero
            shadowLayer.shouldRasterize = true
            self.layer.insertSublayer(shadowLayer, at: 0)
        }

    }

}
