//
//  Layer.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/19/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

extension UIView {
    /// Removes animations from the view layer and its subviews' layers recursively.
    func removeLayerAnimationsRecursively() {
        layer.removeAllAnimations()
        subviews.forEach { $0.removeLayerAnimationsRecursively() }
    }
}
