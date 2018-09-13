//
//  RadioButton.swift
//  machApp
//
//  Created by lukas burns on 5/15/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

@IBDesignable
class RadioButton: UIView {

    @IBOutlet weak var borderButtonView: UIView!
    @IBOutlet weak var insideButtonView: UIView!
    @IBOutlet weak var questionLabel: UILabel!

    @IBInspectable
    public var borderColor: UIColor = UIColor.black {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var selectedBackgroundColor: UIColor = UIColor.black {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var unselectedBackgroundColor: UIColor = UIColor.white {
        didSet {
            setupView()
        }
    }

    // Initialize

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXib()
    }

    func setupView() {
        self.layoutSubviews()
        self.borderButtonView.addBorder(width: 1.0, color: borderColor)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }

    func setupXib() {
        let view = viewFromNibForClass()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }

    private func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "RadioButton", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }

    public func select() {
        self.insideButtonView.backgroundColor = selectedBackgroundColor
        self.questionLabel.boldFont()
    }

    public func unselect() {
        self.insideButtonView.backgroundColor = unselectedBackgroundColor
        self.questionLabel.lightFont()
    }
}
