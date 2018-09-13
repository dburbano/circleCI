//
//  UISearchBar+Style.swift
//  machApp
//
//  Created by lukas burns on 4/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import Foundation

extension UISearchBar {

    func makeTransparent() {
        guard let UISearchBarBackground: AnyClass = NSClassFromString("UISearchBarBackground") else { return }

        for view in self.subviews {
            for subview in view.subviews {
                if subview.isKind(of: UISearchBarBackground) {
                    subview.alpha = 0
                }
            }
        }
    }

    private func getViewElement<T>(type: T.Type) -> T? {
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }

    func getSearchBarTextField() -> UITextField? {
        return getViewElement(type: UITextField.self)
    }

    func setTextFieldBackgroundColor(color: UIColor) {
        if let textField = getSearchBarTextField() {
            textField.backgroundColor = color
        }
    }

    func setTextColor(color: UIColor) {
        if let textField = getSearchBarTextField() {
            textField.textColor = UIColor.white
        }
    }

    func setPlaceHolderTextColor(color: UIColor) {
        if let textField = getSearchBarTextField() {
            textField.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: UIFont.defaultFontLight(size: 16.0)!])
        }
    }

    func setTextFieldColor(color: UIColor) {

        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 6

            case .prominent, .default:
                textField.backgroundColor = color
            }
        }
    }

    func setTextFieldClearButtonColor(color: UIColor) {
        if let textField = getSearchBarTextField() {
            let button = textField.value(forKey: "clearButton") as! UIButton
            if let image = button.imageView?.image {
                button.setImage(image.tintImage(color: UIColor.white), for: .normal)
            }
        }
    }

    func setTextFieldFont(font: UIFont) {
        if let textField = getSearchBarTextField() {
            textField.font = font
        }
    }

    func setSearchImageColor(color: UIColor) {

        if let imageView = getSearchBarTextField()?.leftView as? UIImageView {
            imageView.image = imageView.image?.tintImage(color: UIColor.white)
        }
    }
}
