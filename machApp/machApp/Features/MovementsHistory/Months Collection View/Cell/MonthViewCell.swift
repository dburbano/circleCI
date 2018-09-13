//
//  MonthViewCell.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class MonthViewCell: UICollectionViewCell {

    var monthDate: MonthDate?

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!

    override var isSelected: Bool {
        didSet {
            if isSelected {
                //swiftlint:disable:next force_unwrapping
                monthLabel.font = UIFont(name: "Nunito-Bold", size: 16)!
                monthLabel.textColor = Color.violetBlue
                yearLabel.textColor = Color.violetBlue
            } else {
                //swiftlint:disable:next force_unwrapping
                monthLabel.font = UIFont(name: "Nunito-Regular", size: 16)!
                monthLabel.textColor = Color.greyishBrown
                yearLabel.textColor = Color.greyishBrown
            }
        }
    }

    func inittialize(with monthDate: MonthDate) {
        monthLabel.text = monthDate.month.capitalizedFirst()
        yearLabel.text = monthDate.year
        self.monthDate = monthDate
    }
}
