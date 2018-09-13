//
//  EmptyTableView.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 8/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import Lottie

protocol EmptyTableDelegate: class {
    func didPressCashMach()
}

class EmptyTableView: UIView {

    weak var delegate: EmptyTableDelegate?
    
    lazy var animationView = LOTAnimationView(name: "payMachAnimation")
    
    class func instanceFromNib() -> EmptyTableView? {
        let view = UINib(nibName: "EmptyTableView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? EmptyTableView
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        animationView.addGestureRecognizer(tap)
        animationView.loopAnimation = true
    }

    override func didMoveToSuperview() {
        if let superView = superview {
            leadingAnchor.constraint(equalTo: superView.leadingAnchor)
            trailingAnchor.constraint(equalTo: superView.trailingAnchor)
            topAnchor.constraint(equalTo: superView.topAnchor)
            bottomAnchor.constraint(equalTo: superView.bottomAnchor)

            addAnimationView()
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        delegate?.didPressCashMach()
    }
    
    private func addAnimationView() {
        addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        animationView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75).isActive = true
        animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor, multiplier: 32.0/35.0).isActive = true
    }
    
    func shakeChargeMachButton() {
        animationView.play()
    }
}
