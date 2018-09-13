//
//  MessageTextView.swift
//  machApp
//
//  Created by lukas burns on 5/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol MessageTextViewDelegate: UITextViewDelegate {
    @objc optional func textViewDidChangeHeight(_ textView: MessageTextView, height: CGFloat)
}

@IBDesignable @objc
open class MessageTextView: UITextView {

    // Maximum text length.
    @IBInspectable open var maxLength: Int = 0

    // Trim white spaces when editing.
    @IBInspectable open var trimWhiteSpacesWhenEditing: Bool = true

    // Maximum height of the textView.
    @IBInspectable open var maxHeight: CGFloat = CGFloat(0)

    // Placeholder properties
    // Need to set both placedholder and placeholderColor in order to show placeHolder in the textview
    @IBInspectable open var placeHolder: NSString? {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable open var placeHolderColor: UIColor = UIColor(white: 0.8, alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable open var placeHolderLeftMargin: CGFloat = 5 {
        didSet { setNeedsDisplay() }
    }

    override open var text: String! {
        didSet { setNeedsDisplay() }
    }

    fileprivate weak var heightConstraint: NSLayoutConstraint?

    // Initialize
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 30)
    }

    func associateConstraints() {
        // Iterate through all text view's constraints and identify height
        for constraint in constraints {
            if constraint.firstAttribute == .height {
                if constraint.relation == .equal {
                    self.heightConstraint = constraint
                }
            }
        }
    }

    fileprivate func commonInit() {
        self.contentMode = .redraw
        drawPlaceHolder()
        associateConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing), name: NSNotification.Name.UITextViewTextDidEndEditing, object: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        let size = sizeThatFits(CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        var height = size.height
        if maxHeight > 0 {
            height = min(size.height, maxHeight)
        }

        if heightConstraint == nil {
            heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
            addConstraint(heightConstraint!)
        }

        if height != heightConstraint?.constant {
            self.heightConstraint!.constant = height
            scrollRangeToVisible(NSRange(location: 0, length: 0))
            if let delegate = delegate as? MessageTextViewDelegate {
                delegate.textViewDidChangeHeight?(self, height: height)
            }
        }
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        drawPlaceHolder()
    }

    func drawPlaceHolder() {
        if text.isEmpty {
            guard let placeHolder = placeHolder else { return }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment

            let rect = CGRect(x: textContainerInset.left + placeHolderLeftMargin, y: textContainerInset.top, width: frame.size.width - textContainerInset.left - textContainerInset.right, height: frame.size.height)

            var attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: placeHolderColor, NSAttributedStringKey.paragraphStyle: paragraphStyle]
            if let font = font {
                attributes[NSAttributedStringKey.font] = font
            }

            placeHolder.draw(in: rect, withAttributes: attributes)
        }
    }

    @objc func textDidEndEditing(notification: Notification) {
        if let notificationObject = notification.object as? MessageTextView {
            if notificationObject === self {
                if trimWhiteSpacesWhenEditing {
                    text = text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    setNeedsDisplay()
                }
            }
        }
    }

    @objc func textDidChange(notification: Notification) {
        if let notificationObject = notification.object as? MessageTextView {
            if notificationObject === self {
                if maxLength > 0 && text.count > maxLength {
                    let endIndex = text.index(text.startIndex, offsetBy: maxLength)
                    text = String(text[..<endIndex])
                    undoManager?.removeAllActions()
                }
                setNeedsDisplay()
            }
        }
    }
}
