//
//  Dissapear.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/5/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

extension UILabel {
    func dissapearForASec() {
        // fade-out
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            options: UIViewAnimationOptions.curveEaseOut,
            animations: {
                self.alpha = 0.0
        }, completion: { (_: Bool) -> Void in
            // fade-in
            UIView.animate(
                withDuration: 1.0,
                delay: 0.0,
                options: UIViewAnimationOptions.curveEaseIn,
                animations: {
                    self.alpha = 1.0
            }, completion: nil)
        })
    }
}
