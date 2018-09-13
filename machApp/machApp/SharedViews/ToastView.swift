//
//  ToastView.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class ToastView: UIView, UIGestureRecognizerDelegate {

    private let kHeight: Float = 65.0
    private let kTextLabelHeight: Float = 55.0
    private var delay: Double = 4.4

    var isPresenting: Bool = false

    var blurEffectView: UIVisualEffectView!
    var textLabel: UILabel!

    var bottomCollision: UICollisionBehavior!
    var topCollision: UICollisionBehavior!
    var basicBehavior: UIDynamicItemBehavior!
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!

    var iphoneXDelta: Int = 0

    // some-tricks
    var gestureRecognizer: UIGestureRecognizer!
    var tapGestureHandler: UITapGestureRecognizer!

    init() {
        switch UIDevice.current.size() {
        case .screen5_8Inch:
            self.iphoneXDelta = 32
        default:
            break
        }
        super.init(
            frame: CGRect(
                origin: CGPoint(x: 0, y: Int(-(kHeight + Float(self.iphoneXDelta)))),
                size: CGSize(width: UIScreen.main.bounds.width, height: CGFloat(kHeight + Float(self.iphoneXDelta)))
            )
        )
        setupView()
        setupGestures()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Public methods

    func submit() {
        if !isPresenting {
            self.isPresenting = true
            gravity.gravityDirection = CGVector(dx: gravity.gravityDirection.dx, dy: gravity.gravityDirection.dy * -1)
            self.perform(#selector(ToastView.close), with: nil, afterDelay: delay)
        }
    }

    func configureBehaviors() {
        // black-magic.
        gestureRecognizer = UIGestureRecognizer(target: self, action: nil)
        gestureRecognizer.delegate = self
        // swiftlint:disable:next force_unwrapping
        self.gestureRecognizers![0] = gestureRecognizer

        animator = UIDynamicAnimator(referenceView: UIApplication.shared.keyWindow!)
        // swiftlint:disable:previous force_unwrapping

        gravity = UIGravityBehavior(items: [self])
        gravity.gravityDirection = CGVector(dx: 0, dy: -1)
        animator.addBehavior(gravity)

        bottomCollision = UICollisionBehavior(items: [self])
        bottomCollision.addBoundary(withIdentifier: "bottomBound" as NSCopying,
                                    from: CGPoint(x: 0, y: 65 + iphoneXDelta),
                                    to: CGPoint(x: UIScreen.main.bounds.width, y: 65 + CGFloat(iphoneXDelta) )
        )
        animator.addBehavior(bottomCollision)

        topCollision = UICollisionBehavior(items: [self])
        topCollision.addBoundary(withIdentifier: "topBound" as NSCopying,
                                 from: CGPoint(x: 0, y: -(68 + iphoneXDelta)),
                                 to: CGPoint(x: UIScreen.main.bounds.width, y: -(68 + CGFloat(iphoneXDelta)))
        )
        animator.addBehavior(topCollision)

        basicBehavior = UIDynamicItemBehavior(items: [self])
        basicBehavior.elasticity = 0.3
        animator.addBehavior(basicBehavior)
    }

    func setMessage(text: String) {
        textLabel.text = text
    }

    func setMessage(withFormattedString text: NSAttributedString) {
        textLabel.attributedText = text
    }

    // MARK: Private methods

    private func setupView() {
        self.backgroundColor = UIColor.clear

        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)

        textLabel = UILabel(frame: CGRect(origin: CGPoint(x: 5, y: 10 + iphoneXDelta),
                                          size: CGSize(width: UIScreen.main.bounds.width - 5, height: CGFloat(kTextLabelHeight))))
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center
        textLabel.font = UIFont.bodySmall()
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.blurEffectView.contentView.addSubview(textLabel)
    }

    private func setupGestures() {
        tapGestureHandler = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        tapGestureHandler.delegate = self
        self.addGestureRecognizer(tapGestureHandler)
    }

    // MARK: Gestures

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }

    // MARK: Selectors

    @objc func tapHandler(_ gesture: UITapGestureRecognizer) {
        close()
    }

    @objc func close() {
        gravity.gravityDirection = CGVector(dx: 0, dy: -1)
        self.isPresenting = false
    }
}
