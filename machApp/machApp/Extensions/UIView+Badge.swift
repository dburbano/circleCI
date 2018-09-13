//
//  UIView+Badge.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    private struct AssociatedKeys {
        static var badgeView: UIView?
    }

    public var badgeView: UIView? {
        get {
            if let badge = objc_getAssociatedObject(self, &AssociatedKeys.badgeView) as? UIView {
                return badge
            }
            return nil
        }
        set (newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.badgeView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     Creates a badge at the top-left corner of the view. The text should be a single character-string
     */
    func addBadge(text: String, withColor color: UIColor) {
        if badgeView == nil {
            let width: CGFloat = 15.0
            let height: CGFloat = 15.0

            // Set clip to bounds to false to allow the badge view be outside of the view's frame
            self.clipsToBounds = false

            // Create a rounded teal view
            badgeView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            // seguns los mocks que se tienen, habria que variar entre light-teal/violet-blue
            badgeView?.backgroundColor = color
            badgeView?.layer.cornerRadius = badgeView!.frame.width / 2
            // swiftlint:disable:previous force_unwrapping
            badgeView?.clipsToBounds = true

            // Create the label that will contain the specified text
            let badgeLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
            badgeLabel.text = text
            badgeLabel.font = UIFont.body()
            badgeLabel.textAlignment = .center
            badgeLabel.textColor = UIColor.white

            badgeView?.addSubview(badgeLabel)
            self.addSubview(badgeView!)
            // swiftlint:disable:previous force_unwrapping
        }
    }

    /**
     Removes the badge from its superview, only if the badge is present on it :]
     */
    func removeBadge() {
        if badgeView != nil {
            badgeView?.removeFromSuperview()
            badgeView = nil
        }
    }
}
