//
//  ProgressBarView.swift
//  machApp
//
//  Created by Lukas Burns on 11/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ProgressBarView: UIView {
    
    @IBInspectable
    public var currentStep: Int = 1 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var totalSteps: Int = 3 {
        didSet {
            setupView()
        }
    }
    
    override func draw(_ rect: CGRect) {
        setupView()
    }
    
    private func setupView() {
        let totalProgressBarWidth = self.superview?.bounds.width ?? 0
        let progressWidth = (totalProgressBarWidth / totalSteps.toCGFloat) * (currentStep.toCGFloat - 1)
        self.frame.size.width = progressWidth
    }
    
    func progressToNextStep() {
        let totalProgressBarWidth = self.superview?.bounds.width ?? 0
        let nextStepWidth = (totalProgressBarWidth / totalSteps.toCGFloat) * currentStep.toCGFloat
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            self.frame.size.width = nextStepWidth
        })
//        { _ in
//            UIView.animate(withDuration: 1, delay: 0.0, options: [.autoreverse, .repeat], animations: {
//                self.frame.size.width -= 5
//            })
//        }

    }
}
