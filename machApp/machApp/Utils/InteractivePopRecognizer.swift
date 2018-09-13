//
//  InteractivePopRecognizer.swift
//  machApp
//
//  Created by lukas burns on 5/24/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class InteractivePopRecognizer: NSObject {

    // MARK: - Properties

    fileprivate weak var navigationController: UINavigationController?

    // MARK: - Init

    init(controller: UINavigationController) {
        self.navigationController = controller

        super.init()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}

extension InteractivePopRecognizer: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }

    // This is necessary because without it, subviews of your top controller can cancel out your gesture recognizer on the edge.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
