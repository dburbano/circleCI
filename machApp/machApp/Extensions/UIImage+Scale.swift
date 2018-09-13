//
//  UIImage+Scale.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

extension UIImage {
    func scaleImage() -> UIImage? {
        var scaleValue: CGFloat?
        switch UIDevice.current.modelName {
        case "iPhone 5", "iPhone 5c", "iPhone 5s", "iPhone SE":
            scaleValue = 0.84
        case "iPhone 6", "iPhone 6s", "iPhone 7":
            scaleValue = 1.0
        case "iPhone 6 Plus", "iPhone 6s Plus", "iPhone 7 Plus":
            scaleValue = 1.09
        default:
            // giving that on our sims we use 6-6s-7
            scaleValue = 0.84
        }
        //swiftlint:disable:next force_unwrapping
        let size = self.size.applying(CGAffineTransform(scaleX: scaleValue!, y: scaleValue!))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint(x: 0, y :0), size: size))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

    func scaleBackground() -> UIImage? {
        let scaleValue: CGFloat = 0.97
        let size = self.size.applying(CGAffineTransform(scaleX: scaleValue, y: scaleValue))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint(x: 0, y :0), size: size))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}

extension UIImage {
    // MARK: - UIImage+Resize
    func compressTo(_ expectedSizeInMb: Int) -> Data? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress: Bool = true
        var imgData: Data?
        var compressingValue: CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data: Data = UIImageJPEGRepresentation(self, compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }

        if let data = imgData {
            if (data.count < sizeInBytes) {
                return data
            }
        }
        return UIImageJPEGRepresentation(self, 0.2)
    }
}

extension UIImage {
    class func image(with color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
