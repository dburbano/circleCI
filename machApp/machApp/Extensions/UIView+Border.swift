//
//  UIView+Border.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

extension UIView {
    func addBorderToEdge(edge: UIRectEdge, withColor color: UIColor, andWidth borderWidth: CGFloat) {
        let borderView: UIView = UIView()
        borderView.backgroundColor = color

        if edge == UIRectEdge.top {
            borderView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleTopMargin]
            borderView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: borderWidth)
        }

        if edge == UIRectEdge.left {
            borderView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleLeftMargin]
            borderView.frame = CGRect(x: 0, y: 0, width: borderWidth, height: self.frame.size.height)
        }

        if edge == UIRectEdge.bottom {
            borderView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleBottomMargin]
            borderView.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: borderWidth)
        }

        if edge == UIRectEdge.right {
            borderView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleRightMargin]
            borderView.frame = CGRect(x: self.frame.size.width, y: 0, width: borderWidth, height: self.frame.size.height)
        }
        self.addSubview(borderView)
    }
}
