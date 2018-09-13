//
//  SelectableAccesoryView.swift
//  machApp
//
//  Created by lukas burns on 3/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

@IBDesignable
public class SelectableAccesoryView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.

    override public func draw(_ rect: CGRect) {
        // Drawing code
        self.setCornerRadius(radius: self.w/2)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        let selectedImageView = UIImageView(image: UIImage(named: "icCheck"))
        selectedImageView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.addSubview(selectedImageView)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func select() {
        self.backgroundColor = Color.aquamarine
    }

    func unselect() {
        self.backgroundColor = .white
    }
}
