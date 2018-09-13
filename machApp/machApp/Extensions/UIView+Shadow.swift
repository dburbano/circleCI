//
//  UIView+Shadow.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

extension UIView {

    func addTinyShadow () {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 0.5
        layer.shadowOpacity = 0.3
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func addBigShadow () {
        layer.shadowOffset = CGSize(width: 0, height: 3.5)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.65
        layer.shadowRadius = 2.5
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func addShadowChargeVC () {
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3.5
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
    }

}
