//
//  PasscodePlaceholderView.swift
//  machApp
//
//  Created by lukas burns on 3/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

@IBDesignable
public class PasscodePlaceholderView: UIView {

    public enum State {
        case inactive
        case active
        case error
    }

    @IBInspectable
    public var inactiveColor: UIColor = UIColor.clear {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var borderColor: UIColor = UIColor.white {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var activeImage: UIImage? = nil {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var errorColor: UIColor = UIColor.red {
        didSet {
            setupView()
        }
    }

    var letterImageView: UIImageView?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
    }

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 16, height: 16)
    }

    private func setupView() {
        layer.cornerRadius = self.w / 2
        backgroundColor = inactiveColor
        self.addBorder(width: 1, color: borderColor)
        guard let letter = self.activeImage else {
            return
        }
        letterImageView = UIImageView(image: letter)
    }

    public func animateState(state: State) {

        switch state {
        case .active:
            self.layer.masksToBounds = false
            self.layer.borderColor = UIColor.clear.cgColor
            self.addSubview(self.letterImageView!)
            self.letterImageView?.centerInSuperView()
        case .inactive:
            self.letterImageView?.removeFromSuperview()
            self.backgroundColor = inactiveColor
            self.layer.borderColor = borderColor.cgColor
        case.error:
            self.letterImageView?.removeFromSuperview()
            self.backgroundColor = inactiveColor
            self.layer.borderColor = borderColor.cgColor
        }

//        UIView.animate(
//            withDuration: 0.5,
//            delay: 0,
//            usingSpringWithDamping: 1,
//            initialSpringVelocity: 0,
//            options: [],
//            animations: {
//                self.backgroundColor = colors.backgroundColor
//                self.layer.borderColor = colors.borderColor.cgColor
//        },
//            completion: nil
//        )
    }

}
