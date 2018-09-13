//
//  UIFont+Mach.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

extension UIFont {

    private enum FontSize: CGFloat {
        case bigger = 40.0
        case big = 29.0
        case header = 20.0
        case bodyTitle = 18.0
        case body = 16.0
        case bodySmall = 15.0
        case small = 14.0
    }

    class func defaultFont(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-Regular", size: size)
    }

    class func defaultFontBold(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-Bold", size: size)
    }

    class func defaultFontLight(size: CGFloat) -> UIFont? {
        return UIFont(name: "Nunito-Light", size: size)
    }

    private func withTraits(traits: UIFontDescriptorSymbolicTraits...) -> UIFont? {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
        // swiftlint:disable:previous force_unwrapping
    }

    class func bigger() -> UIFont? {
        return defaultFont(size: FontSize.bigger.rawValue)
    }

    class func big() -> UIFont? {
        return defaultFont(size: FontSize.big.rawValue)
    }

    class func body() -> UIFont? {
        return defaultFont(size: FontSize.body.rawValue)
    }

    class func bodyBold() -> UIFont? {
        return defaultFontBold(size: FontSize.body.rawValue)
    }

    class func bodyTitle() -> UIFont? {
        return defaultFont(size: FontSize.bodyTitle.rawValue)
    }

    class func bodyTitleItalic() -> UIFont? {
        return bodyTitle()?.withTraits(traits: .traitItalic)
    }

    class func bodyTitleBold() -> UIFont? {
        return bodyTitle()?.withTraits(traits: .traitBold)
    }

    class func bodySmall() -> UIFont? {
        return defaultFont(size: FontSize.bodySmall.rawValue)
    }

    class func bodySmallItalic() -> UIFont? {
        return bodySmall()?.withTraits(traits: .traitItalic)
    }

    class func bodySmallBold() -> UIFont? {
        return bodySmall()?.withTraits(traits: .traitBold)
    }

    class func header() -> UIFont? {
        return defaultFont(size: FontSize.header.rawValue)
    }

    class func headerBold() -> UIFont? {
        return header()?.withTraits(traits: .traitBold)
    }

    class func small() -> UIFont? {
        return defaultFont(size: FontSize.small.rawValue)
    }

    class func smallItalic() -> UIFont? {
        return small()?.withTraits(traits: .traitItalic)
    }

    class func smallBold() -> UIFont? {
        return defaultFontBold(size: FontSize.small.rawValue)
    }
}
