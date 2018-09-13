//
//  NavigationController+Style.swift
//  machApp
//
//  Created by lukas burns on 4/25/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {

    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return visibleViewController
    }

}

extension UIPageViewController {

    override open var childViewControllerForStatusBarStyle: UIViewController? {
        return viewControllers?.first
    }
}
