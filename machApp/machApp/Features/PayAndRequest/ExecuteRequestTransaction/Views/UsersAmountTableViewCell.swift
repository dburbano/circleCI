//
//  UsersAmountTableViewCell.swift
//  machApp
//
//  Created by Rodrigo Russell on 3/6/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit
import SDWebImage

class UsersAmountTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!

    var userAmountViewModel: UserAmountViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    func setupView() {
        let view: UIView? = loadViewFromNib()
        view?.frame = bounds
        view?.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        guard let customView = view else {
            return
        }
        self.contentView.addSubview(customView)
        self.layoutSubviews()
    }

    func loadViewFromNib() -> UIView? {
        let nibName = "UsersAmountTableViewCell"
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func initializeWith(userAmountViewModel: UserAmountViewModel) {
        self.userAmountViewModel = userAmountViewModel
        self.amountLabel?.text = userAmountViewModel.amount.toCurrency()
        self.firstNameLabel?.text = userAmountViewModel.firstNameToShow
        self.lastNameLabel?.text = userAmountViewModel.lastNameToShow
        self.profileImageView?.sd_setImage(with: userAmountViewModel.profileImageUrl, placeholderImage: userAmountViewModel.profileImage)
    }

}
