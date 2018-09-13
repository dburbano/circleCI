//
//  UIView+Avatar.swift
//  machApp
//
//  Created by lukas burns on 6/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    static func getAvatar(phoneNumber: String?, firstName: String?, lastName: String?) -> UIView {

        let avatarColor = getColor(for: phoneNumber)

        let avatarView = UIView(x: 0, y: 0, w: 60, h: 60)
        avatarView.backgroundColor = UIColor.white
        avatarView.clipsToBounds = true
        avatarView.setCornerRadius(radius: avatarView.w/2)
        avatarView.addBorder(width: 5.0, color: avatarColor.withAlphaComponent(0.5))

        let labelName = UILabel(x: 0, y: 0, w: 40, h: 30)
        var firstLetter = ""
        var secondLetter = ""

        if let firstCharacterOfFirstName = firstName?.first?.uppercased {
            firstLetter = firstCharacterOfFirstName.toString
        }
        if let firstCharacterOfLastName = lastName?.first?.uppercased {
            secondLetter = firstCharacterOfLastName.toString
        }

        labelName.text = "\(firstLetter)\(secondLetter)"
        labelName.textColor = avatarColor
        labelName.font = UIFont.defaultFontBold(size: 18)
        labelName.textAlignment = NSTextAlignment.center
        labelName.minimumScaleFactor = 0.8

        labelName.center = avatarView.center
        avatarView.addSubview(labelName)

        return avatarView
    }

    private static func getColor(for phoneNumber: String?) -> UIColor {
        let colors = [Color.aquamarine, Color.dodgerBlue, Color.reddishPink, Color.violetBlue]
        guard let lastNumber = phoneNumber?.cleanPhoneNumber().last?.toInt else {
            return colors[0]
        }
        return colors[lastNumber % 4]
    }

    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            //Fallback on earlier versions
            return UIImage(view: self)
        }
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
}
