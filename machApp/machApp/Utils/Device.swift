//
//  Device.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

public extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }

    func size() -> Size {
        let w: Double = Double(UIScreen.main.bounds.width)
        let h: Double = Double(UIScreen.main.bounds.height)
        let screenHeight: Double = max(w, h)

        switch screenHeight {
        case 480:
            return Size.screen3_5Inch
        case 568:
            return Size.screen4Inch
        case 667:
            return UIScreen.main.scale == 3.0 ? Size.screen5_5Inch : Size.screen4_7Inch
        case 736:
            return Size.screen5_5Inch
        case 812:
            return Size.screen5_8Inch
        case 1366:
            return Size.screen12_9Inch
        default:
            return Size.unknownSize
        }
    }

    class func hasSmallScreen() -> Bool {
        let modelName: String = UIDevice.current.modelName
        return modelName == "iPad 2" || modelName == "iPad 3" || modelName == "iPad 4" ||
            modelName == "iPad Air" || modelName == "iPad Air 2" || modelName == "iPad Mini" ||
            modelName == "iPad Mini 2" || modelName == "iPad Mini 3" || modelName == "iPad Mini 4" ||
            modelName == "iPhone 4s"
    }

    class func hasMediumScreen() -> Bool {
        let modelName: String = UIDevice.current.modelName
        return modelName == "iPhone 5" || modelName == "iPhone 5c" || modelName == "iPhone 5s" || modelName == "iPhone SE"
    }

}

// swiftlint:disable identifier_name
public enum Size: Int {
    case unknownSize = 0
    case screen3_5Inch
    case screen4Inch
    case screen4_7Inch
    case screen5_5Inch
    case screen5_8Inch
    case screen7_9Inch
    case screen9_7Inch
    case screen12_9Inch
}
