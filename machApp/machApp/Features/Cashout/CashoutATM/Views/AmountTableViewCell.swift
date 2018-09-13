//
//  AmountTableViewCell.swift
//  machApp
//
//  Created by Rodrigo Russell on 12/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class AmountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var contentViewCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        applyStyling()
    }
    
    func applyStyling() {
        let view: UIView? = loadViewFromNib()
        view?.frame = bounds
        view?.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        guard let customView = view else {
            return
        }
        contentView.addSubview(customView)
        layoutSubviews()
    }
    
    func loadViewFromNib() -> UIView? {
        let nibName = "AmountTableViewCell"
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func setupCell(with amount: Int) {
        self.amountLabel?.text = amount.toCurrency()
    }

}
