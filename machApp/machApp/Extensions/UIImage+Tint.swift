//
//  UIImage+Tint.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

extension UIImage {

    func tintImage(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        // swiftlint:disable:previous force_unwrapping

        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        let rect: CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context.setBlendMode(CGBlendMode.normal)
        context.draw(self.cgImage!, in: rect) // swiftlint:disable:this force_unwrapping
        context.setBlendMode(CGBlendMode.sourceIn)
        color.setFill()
        context.fill(rect)

        // swiftlint:disable:next force_unwrapping
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // Creates Image from color
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
