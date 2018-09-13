//
//  UILabel+Bold.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

extension UILabel {

    // just make the entire label bold.
    func boldFont() {
        let boldFont: UIFont? = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        self.font = boldFont
    }
    
    func nunitoBoldFont(size: Float) {
        let boldFont: UIFont? = UIFont(name: "Nunito-Bold", size: CGFloat(size))
        self.font = boldFont
    }

    func lightFont() {
        let lightFont: UIFont? = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.light)
        self.font = lightFont
    }

    // make-bold given a range.
    func boldSentence(first: String, boldText: String) {
        let attributedString = NSMutableAttributedString(string: first)
        let attrs = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15),
                     NSAttributedStringKey.foregroundColor: Color.greyishBrown]
        let boldString = NSMutableAttributedString(string: boldText, attributes: attrs)
        attributedString.append(boldString)
        self.attributedText = attributedString
    }

    func semiBoldSentence(first: String, boldText: String) {
        let attributedString = NSMutableAttributedString(string: first)
        let attrs = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold),
                     NSAttributedStringKey.foregroundColor: Color.greyishBrown]
        let boldString = NSMutableAttributedString(string: boldText, attributes: attrs)
        attributedString.append(boldString)
        self.attributedText = attributedString
    }
    
    func twoColorSentence(firstText: String, secondText: String) {
        let attributedString = NSMutableAttributedString(string: firstText)
        let attrs = [NSAttributedStringKey.font: UIFont(name: "Nunito-Regular", size: 17.0)!, NSAttributedStringKey.foregroundColor: Color.greyishBrown]
        let secondColorText = NSMutableAttributedString(string: secondText, attributes: attrs)
        attributedString.append(secondColorText)
        self.attributedText = attributedString
    }
    

}
