//
//  WithdrawInstructionsTableViewCell.swift
//  machApp
//
//  Created by Rodrigo Russell on 1/5/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class WithdrawInstructionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionImage: RoundedImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setupCell(with title: String) {
        self.titleLabel?.text = title
    }
    
}

