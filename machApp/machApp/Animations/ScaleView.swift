//
//  ScaleView.swift
//  machApp
//
//  Created by lukas burns on 7/21/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    func showScaling(into superView: UIView?) {
        guard let superView = superView else { return }
        self.alpha = 1
        self.transform = CGAffineTransform.identity
        let overlayView = UIView(frame: CGRect(x: superView.x, y: superView.y, w: superView.w, h: superView.h))
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        superView.addSubview(overlayView)
        superView.addSubview(self)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        }, completion: { _ in

        })
    }

    func hideUnscaling(from superView: UIView?) {
        guard let superView = superView else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.alpha = 0
            superView.subviews[superView.subviews.count - 2].backgroundColor = UIColor.black.withAlphaComponent(0.0)
        }, completion: { _ in
            self.removeFromSuperview()
            superView.subviews.last?.removeFromSuperview()
        })
    }
}
