//
//  PaymentSentTableViewCell.swift
//  machApp
//
//  Created by lukas burns on 4/10/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class PaymentSentTableViewCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var nearTransactionImageView: UIImageView!

    @IBOutlet weak var interactionLabel: UILabel!
    @IBOutlet weak var interactionStackView: UIStackView!
    @IBOutlet weak var interactionImageView: UIImageView!
    var transactionViewModel: TransactionViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        let nibName = "PaymentSentTableViewCell"
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func setupCellWith(transactionViewModel: TransactionViewModel) {
        self.transactionViewModel = transactionViewModel
        self.setAmount()
        self.setMessage()
        self.setTime()
        self.setNearTransactionImage()
        self.setInteraction()
    }

    private func setAmount() {
        self.amountLabel.text = transactionViewModel?.amount.toCurrency()
    }

    private func setMessage() {
        self.messageLabel.text = transactionViewModel?.message ?? ""
    }

    private func setTime() {
        self.hourLabel.text = transactionViewModel?.createdAt?.getHourAndMinutes()
    }

    private func setNearTransactionImage() {
        if let transactionViewModel = transactionViewModel, transactionViewModel.wasTransactionOriginatedByProximity() {
            self.nearTransactionImageView.isHidden = false
        } else {
            self.nearTransactionImageView.isHidden = true
        }
    }

    private func setInteraction() {
        guard let transactionViewModel = transactionViewModel else { return }
        if let interactionViewModel = transactionViewModel.getLastInteraction() {
            self.interactionStackView.isHidden = false
            self.interactionLabel.text = interactionViewModel.message
            if let imageUrl = interactionViewModel.imageUrl {
                self.interactionImageView.image = UIImage(urlString: imageUrl.absoluteString)
            }
        } else {
            self.interactionStackView.isHidden = true
        }
    }
}
