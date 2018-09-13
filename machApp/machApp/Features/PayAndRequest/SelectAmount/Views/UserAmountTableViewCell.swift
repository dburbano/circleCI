//
//  UserAmountTableViewCell.swift
//  machApp
//
//  Created by lukas burns on 3/24/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import SDWebImage

@IBDesignable
class UserAmountTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var isMachImageView: UIImageView!

    var userAmountViewModel: UserAmountViewModel?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        let nibName = "UserAmountTableViewCell"
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
        self.isMachImageView.isHidden = true // !userAmountViewModel.isMach
    }
}
