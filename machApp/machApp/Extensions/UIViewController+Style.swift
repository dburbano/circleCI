//
//  UIView+Style.swift
//  machApp
//
//  Created by lukas burns on 4/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import Foundation

extension UIViewController {

    private struct AssociatedKeys {
        static var gradientView: UIView?
    }

    public var gradientView: UIView? {
        get {
            if let gradientView = objc_getAssociatedObject(self, &AssociatedKeys.gradientView) as? UIView {
                return gradientView
            }
            return nil
        }
        set (newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.gradientView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func setMachGradient(for views: [UIView], includesStatusBar: Bool = true, includesNavigationBar: Bool = true, withRoundedBottomCorners: Bool = true) {
        self.navBar?.backgroundColor = UIColor.clear
        let gradient = CAGradientLayer()
        var heightSum: CGFloat = includesStatusBar ? (UIApplication.shared.statusBarView?.h ?? 0) : 0.0
        heightSum += includesNavigationBar ? (navBar?.h ?? 0) : 0.0

        let yOffset = heightSum
        for view in views {
            heightSum += view.h
            view.backgroundColor = UIColor.clear
        }
        gradient.frame = CGRect(x: 0, y: -1 * yOffset, width: self.view.w, height: heightSum + yOffset)
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.colors = [Color.violetBlue.cgColor, Color.dodgerBlue.cgColor]
        if gradientView != nil {
           gradientView?.removeFromSuperview()
        }

        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: gradient.bounds, byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight], cornerRadii: CGSize(width: 15.0, height: 15.0)).cgPath
        gradient.mask = maskLayer
        gradient.shadowOpacity = 0.8
        gradient.shadowRadius = 1.0
        gradient.shadowColor = UIColor.black.cgColor
        gradient.shadowOffset = CGSize.zero
        gradient.masksToBounds = false

        self.view.layer.insertSublayer(gradient, at: 0)

//        gradient.masksToBounds = true
//        gradientView = UIView(frame: gradient.frame)
//        gradientView?.layer.masksToBounds = true
//        if withRoundedBottomCorners {
//            // gradientView!.roundBottomCorners()
//        }
//        gradientView?.layer.addSublayer(gradient)
//        self.view.insertSubview(gradientView!, at: 0)
    }
}

extension UIAlertController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
