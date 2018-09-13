//
//  Draw.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func drawFrom(start: CGPoint, toPoint end: CGPoint, ofColor lineColor: UIColor, inView view: UIView) {

        //create a path
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)

        //create a shape, and add the path to it
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 1.0

        //if we are at the end of the view, move the view left by 10, and add the 10 to the right, making it roll
        if end.x > view.frame.width * 0.95 {
            let newRect = CGRect(x: view.frame.origin.x-10, y: view.frame.origin.y, width: view.frame.width+10, height: view.frame.height)
            view.frame = newRect
        }

        //wait till there iss data to show, so we don't get a huge spike from 0.0
        if start != CGPoint.zero {
            view.layer.addSublayer(shapeLayer)
        }
    }
}
