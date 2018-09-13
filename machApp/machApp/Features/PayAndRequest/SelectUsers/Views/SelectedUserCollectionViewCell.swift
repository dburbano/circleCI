//
//  SelectedUserCollectionViewCell.swift
//  machApp5
//
//  Created by lukas burns on 3/20/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

protocol RemovableCollectionViewCellDelegate: class {
    func removeViewCell(cell: UICollectionViewCell)
}

class SelectedUserCollectionViewCell: UICollectionViewCell {

    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet weak var removeUserButton: UIButton!

    weak var delegate: RemovableCollectionViewCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func initializeWith(user: SelectUserViewModel?) {
        guard let user = user else { return }
        self.profileImageView.sd_setImage(with: user.profileImageUrl, placeholderImage: user.profileImage)
        self.firstNameLabel?.text = user.firstNameToShow
    }

    @IBAction func removeButtonAction(_ sender: UIButton) {
        self.delegate?.removeViewCell(cell: self)
    }
}
