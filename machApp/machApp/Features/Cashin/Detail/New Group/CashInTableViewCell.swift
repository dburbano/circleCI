//
//  CashInTableViewCell.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class CashInTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var middleLabel: UILabel!

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
        let nibName = "CashInTableViewCell"
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func setupCellWith(index: IndexPath) {
        switch index.section {
        case 0:
            middleLabel.text = "Transferencia Bancaria"
        case 1:
            switch index.row {
            case 0:
                middleLabel.text = "Recarga de Celulares"
            case 1:
                middleLabel.text = "Recarga tu Bip"
            case 2:
                middleLabel.text = "Recarga DirectTV"
            default:
                break
            }
        default:
            break
        }
    }
}
