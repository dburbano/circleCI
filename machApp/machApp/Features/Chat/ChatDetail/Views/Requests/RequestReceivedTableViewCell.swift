//
//  RequestReceivedTableViewCell.swift
//  machApp
//
//  Created by lukas burns on 5/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

protocol RequestReceivedDelegate: class {
    func requestAccepted(cell: RequestReceivedTableViewCell)
    func requestRejected(cell: RequestReceivedTableViewCell)
}

class RequestReceivedTableViewCell: UITableViewCell {

    // MARK: - Variables
    var transactionViewModel: TransactionViewModel?

    weak var delegate: RequestReceivedDelegate?

    @IBOutlet weak var userInteractedImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var closedHourLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var actionButtonsStackView: UIStackView!
    @IBOutlet weak var nearTransactionImageView: UIImageView!
    @IBOutlet weak var rejectButton: RoundedButton!
    @IBOutlet weak var acceptButton: RoundedButton!

    @IBOutlet weak var reminderIconImage: UIImageView!
    @IBOutlet weak var interactionImageView: UIImageView!
    @IBOutlet weak var interactionLabel: UILabel!
    @IBOutlet weak var interactionStackView: UIStackView!
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
        self.unblockActions()
        self.contentView.addSubview(customView)
        self.layoutSubviews()
    }

    func loadViewFromNib() -> UIView? {
        let nibName = "RequestReceivedTableViewCell"
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func setupCellWith(transactionViewModel: TransactionViewModel) {
        self.transactionViewModel = transactionViewModel
        self.setUserInteractedImage()
        self.setNearTransactionImage()
        self.setMessage()
        self.setInteraction()

        if transactionViewModel.isClosed() {
            self.actionButtonsStackView.isHidden = true
            self.closedHourLabel.isHidden = false
        } else {
            self.actionButtonsStackView.isHidden = false
            self.closedHourLabel.isHidden = true
        }

        switch transactionViewModel.getTransactionStatus() {
        case .completed:
            setAsCompleted(transactionViewModel: transactionViewModel)
        case .pending:
            setAsPending(transactionViewModel: transactionViewModel)
        case .cancelled:
             setAsCancelled(transactionViewModel: transactionViewModel)
        case .rejected:
            setAsRejected(transactionViewModel: transactionViewModel)
        default:
            break
        }
    }

    func setUserInteractedImage() {
        if let transactionViewModel = transactionViewModel, let imageUrl = transactionViewModel.createdBy?.profileImageUrl {
            self.userInteractedImageView.sd_setImage(with: imageUrl, placeholderImage: transactionViewModel.createdBy?.profileImage)
        } else {
            self.userInteractedImageView.image = transactionViewModel?.createdBy?.profileImage
        }
    }

    func blockActions() {
        self.acceptButton.isEnabled = false
        self.rejectButton.isEnabled = false
    }

    func unblockActions() {
        self.acceptButton.isEnabled = true
        self.rejectButton.isEnabled = true
    }

    private func setNearTransactionImage() {
        if let transactionViewModel = transactionViewModel, transactionViewModel.wasTransactionOriginatedByProximity() {
            self.nearTransactionImageView.isHidden = false
        } else {
            self.nearTransactionImageView.isHidden = true
        }
    }

    private func setMessage() {
        self.messageLabel.text = transactionViewModel?.message ?? ""
    }

    private func setAsCompleted(transactionViewModel: TransactionViewModel) {
        self.amountLabel.attributedText = nil
        self.statusLabel.text = "PAGADO"
        self.statusLabel.textColor = Color.reddishPink
        self.statusImageView.image = #imageLiteral(resourceName: "icCheck-1").tintImage(color: Color.reddishPink)
        self.hourLabel.text = transactionViewModel.createdAt?.getRelativeDateAndTime()
        self.amountLabel.textColor = Color.reddishPink
        self.amountLabel.text = transactionViewModel.amount.toCurrency()
        self.closedHourLabel.text = transactionViewModel.completedAt?.getHourAndMinutes()
        self.closedHourLabel.textColor = Color.reddishPink
    }

    private func setAsPending(transactionViewModel: TransactionViewModel) {
        self.amountLabel.attributedText = nil
        self.statusLabel.text = "PENDIENTE"
        self.statusLabel.textColor = Color.greyishBrown
        self.statusImageView.image = #imageLiteral(resourceName: "icClock").tintImage(color: Color.greyishBrown)
        self.hourLabel.text = transactionViewModel.createdAt?.getHourAndMinutes()
        self.amountLabel.textColor = Color.pinkishGrey
        self.amountLabel.text = transactionViewModel.amount.toCurrency()
    }

    private func setAsCancelled(transactionViewModel: TransactionViewModel) {
        self.amountLabel.attributedText = transactionViewModel.amount.toCurrency().strikedThrough()
        self.amountLabel.textColor = Color.pinkishGrey
        self.statusLabel.text = "DESCARTADO"
        self.statusLabel.textColor = Color.greyishBrown
        self.statusImageView.image = #imageLiteral(resourceName: "icCancelled").tintImage(color: Color.greyishBrown)
        self.hourLabel.text = transactionViewModel.createdAt?.getRelativeDateAndTime()
        self.closedHourLabel.text = transactionViewModel.cancelledAt?.getHourAndMinutes()
        self.closedHourLabel.textColor = Color.greyishBrown
    }

    private func setAsRejected(transactionViewModel: TransactionViewModel) {
        self.statusLabel.text = "RECHAZADO"
        self.statusLabel.textColor = Color.greyishBrown
        self.statusImageView.image = #imageLiteral(resourceName: "icCancelled").tintImage(color: Color.greyishBrown)
        self.hourLabel.text = transactionViewModel.createdAt?.getRelativeDateAndTime()
        self.amountLabel.textColor = Color.pinkishGrey
        self.amountLabel.attributedText = transactionViewModel.amount.toCurrency().strikedThrough()
        self.closedHourLabel.text = transactionViewModel.rejectedAt?.getHourAndMinutes()
        self.closedHourLabel.textColor = Color.greyishBrown
    }

    private func setInteraction() {
        guard let transactionViewModel = transactionViewModel else { return }
        if let interactionViewModel = transactionViewModel.getLastInteraction() {
            self.reminderIconImage.isHidden = true
            switch transactionViewModel.getTransactionStatus() {
            case .completed:
                if interactionViewModel.interaction.type == InteractionType.paymentReactionInteraction.rawValue {
                    self.showReactionInformation(interactionViewModel)
                } else {
                    self.interactionStackView.isHidden = true
                }
            case .cancelled:
                self.interactionStackView.isHidden = true
            case .pending:
                self.reminderIconImage.isHidden = false
                fallthrough
            default:
                self.showReactionInformation(interactionViewModel)
            }
        } else {
            self.interactionStackView.isHidden = true
        }
    }

    private func showReactionInformation(_ interactionViewModel: InteractionViewModel) {
        self.interactionStackView.isHidden = false
        self.interactionLabel.text = interactionViewModel.message
        if let imageUrl = interactionViewModel.imageUrl {
            self.interactionImageView.image = UIImage(urlString: imageUrl.absoluteString)
        }
    }

    // MARK: - Actions

    @IBAction func rejectActionPressed(_ sender: Any) {
        self.delegate?.requestRejected(cell: self)
    }

    @IBAction func payActionPressed(_ sender: Any) {
        self.delegate?.requestAccepted(cell: self)
    }

}
