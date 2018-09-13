//
//  UserTableViewCell.swift
//  machApp
//
//  Created by lukas burns on 3/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import Contacts
import SDWebImage
import RealmSwift

@IBDesignable
class SelectUserTableViewCell: UITableViewCell {

    var selectUserViewModel: SelectUserViewModel?
    var notificationToken: NotificationToken?

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var isMachImageView: UIImageView!
    @IBOutlet weak var isContactNearImageView: UIImageView!

    var selectableAccesoryView: SelectableAccesoryView? {
        if let customAccesoryView = self.accessoryView as? SelectableAccesoryView {
            return customAccesoryView
        } else {
            return nil
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.accessoryType = .none
        self.accessoryView = SelectableAccesoryView(x: 0, y: 0, w: 26, h: 26)
    }

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
        let nibName = "SelectUserTableViewCell"
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func markAsSelected() {
        selectableAccesoryView?.select()
    }

    func markAsUnselected() {
        selectableAccesoryView?.unselect()
    }

    func initializeWith(user: SelectUserViewModel, sortOrder: CNContactSortOrder, viewMode: ViewMode?) {
        self.selectUserViewModel = user
        loadCellWithUserData()

        //Add an alpha if the user is on the onboarding phase
        if let viewMode = viewMode {
            switch viewMode {
            case .chargeMach:
                contentView.alpha = 0.5
                isUserInteractionEnabled = false
            default:
                break
            }
        }
    }

    private func loadCellWithUserData() {
        self.setNameLabels()
        self.setProfileImage()
        self.setIsUserSelectedIcon()
        self.setNearTransactionIcon()
        self.setIsMachUserIcon()
    }

    private func setNameLabels() {
        guard let selectUserViewModel = self.selectUserViewModel else { return }
        let sortOrder = CNContactsUserDefaults.shared().sortOrder
        if sortOrder == .familyName && selectUserViewModel.isFirstNameFirst {
            self.firstNameLabel.text = selectUserViewModel.firstNameToShow
            self.lastNameLabel.text = selectUserViewModel.lastNameToShow
            self.lastNameLabel.boldFont()
        } else if sortOrder == .familyName && !selectUserViewModel.isFirstNameFirst {
            self.firstNameLabel.text = selectUserViewModel.lastNameToShow
            self.lastNameLabel.text = selectUserViewModel.firstNameToShow
            self.firstNameLabel.boldFont()
        } else if sortOrder == .givenName && selectUserViewModel.isFirstNameFirst {
            self.firstNameLabel.text = selectUserViewModel.firstNameToShow
            self.lastNameLabel.text = selectUserViewModel.lastNameToShow
            self.firstNameLabel.boldFont()
        } else if sortOrder == .givenName && !selectUserViewModel.isFirstNameFirst {
            self.firstNameLabel.text = selectUserViewModel.lastNameToShow
            self.lastNameLabel.text = selectUserViewModel.firstNameToShow
            self.lastNameLabel.boldFont()
        } else {
            self.firstNameLabel.text = selectUserViewModel.firstNameToShow
            self.lastNameLabel.text = selectUserViewModel.lastNameToShow
            self.lastNameLabel.boldFont()
        }
    }

    private func setProfileImage() {
        guard let selectUserViewModel = self.selectUserViewModel else { return }
        self.profileImageView.sd_setImage(with: selectUserViewModel.profileImageUrl, placeholderImage: selectUserViewModel.profileImage)
    }

    private func setIsUserSelectedIcon() {
        guard let selectUserViewModel = self.selectUserViewModel else { return }
        selectUserViewModel.isSelected ? markAsSelected() : markAsUnselected()
    }

    private func setNearTransactionIcon() {
        guard let selectUserViewModel = self.selectUserViewModel else { return }
        self.isContactNearImageView.isHidden = !selectUserViewModel.isNear
    }

    private func setIsMachUserIcon() {
        guard let selectUserViewModel = self.selectUserViewModel else { return }
        self.isMachImageView.isHidden = !selectUserViewModel.isMach
    }

}
