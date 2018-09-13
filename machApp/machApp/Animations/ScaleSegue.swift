//
//  ScaleSegue.swift
//  machApp
//
//  Created by lukas burns on 5/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class ScaleSegue: UIStoryboardSegue {

    override func perform() {
        scale()
    }

    func scale() {
        let toViewController = self.destination
        let fromViewController = self.source

        toViewController.view.backgroundColor = UIColor.clear

        let originalCenter = fromViewController.view.center

        toViewController.view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        toViewController.view.center = originalCenter

        let overlayView = UIView(frame: CGRect(x: fromViewController.view.x, y: fromViewController.view.y, w: fromViewController.view.w, h: fromViewController.view.h))

        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0)

        fromViewController.view.addSubview(overlayView)
        fromViewController.view.addSubview(toViewController.view)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            toViewController.view.transform = CGAffineTransform.identity
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        }, completion: { _ in
            fromViewController.addChildViewController(toViewController)
        })
    }

}

class UnwindScaleSegue: UIStoryboardSegue {
    override func perform() {
        scale()
    }

    func scale() {
        let fromViewController = self.source
        let toViewController = self.destination

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            fromViewController.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            fromViewController.view.alpha = 0
            toViewController.view.subviews.last?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        }, completion: { _ in
            fromViewController.removeFromParentViewController()
            toViewController.view.subviews.last?.removeFromSuperview()
            toViewController.view.subviews.last?.removeFromSuperview()
        })
    }
}
