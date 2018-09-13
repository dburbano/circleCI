//
//  RequestSentTableViewCell.swift
//  machApp
//
//  Created by lukas burns on 5/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

protocol RequestSentDelegate: class {
    func requestCanceled(cell: RequestSentTableViewCell)
}

class RequestSentTableViewCell: UITableViewCell {

    // MARK: - Variables
    var transactionViewModel: TransactionViewModel?

    weak var delegate: RequestSentDelegate?
    var openInteractionsDelegate: OpenInteractionsDelegate?

    @IBOutlet weak var remindButton: LoadingButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var closedHourLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var actionButtonsStackView: UIStackView!
    @IBOutlet weak var nearTransactionImageView: UIImageView!
    @IBOutlet weak var cancelButton: RoundedButton!
    @IBOutlet weak var interactionStackView: UIStackView!
    @IBOutlet weak var interactionLabel: UILabel!
    @IBOutlet weak var maximumRemindersLabel: UILabel!
    @IBOutlet weak var remindersSentLabel: UILabel!
    @IBOutlet weak var interactionImageView: UIImageView!
    @IBOutlet weak var reminderIconImage: UIImageView!
    @IBOutlet weak var numberOfRemindersSentStackView: UIStackView!
    @IBOutlet weak var addInteractionStackView: UIStackView!
    @IBOutlet weak var addInteractionButton: UIButton!
    @IBOutlet weak var addInteractionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tooltipView: UIView!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!

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
        let nibName = "RequestSentTableViewCell"
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func setupCellWith(transactionViewModel: TransactionViewModel, tooltipFlag: Bool) {
        self.transactionViewModel = transactionViewModel
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

        tooltipView?.isHidden = tooltipFlag
        //If the tooltip is hidden, we need to remove it. 
        if tooltipFlag {
            tooltipView?.removeFromSuperview()
            contentViewBottomConstraint.priority = UILayoutPriority.defaultHigh
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

    func blockActions() {
        cancelButton.isEnabled = false
    }

    func unblockActions() {
        cancelButton.isEnabled = true
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
        self.amountLabel.text = transactionViewModel.amount.toCurrency()
        self.amountLabel.textColor = Color.dodgerBlue
        self.statusLabel.text = "PAGADO"
        self.statusLabel.textColor = Color.dodgerBlue
        self.statusImageView.image = #imageLiteral(resourceName: "icCheck-1").tintImage(color: Color.dodgerBlue)
        self.hourLabel.text = transactionViewModel.createdAt?.getRelativeDateAndTime()
        self.closedHourLabel.text = transactionViewModel.completedAt?.getHourAndMinutes()
        self.closedHourLabel.textColor = Color.dodgerBlue
    }

    private func setAsPending(transactionViewModel: TransactionViewModel) {
        self.amountLabel.attributedText = nil
        self.amountLabel.text = transactionViewModel.amount.toCurrency()
        self.amountLabel.textColor = Color.pinkishGrey
        self.statusLabel.text = "PENDIENTE"
        self.statusLabel.textColor = Color.greyishBrown
        self.statusImageView.image = #imageLiteral(resourceName: "icClock").tintImage(color: Color.greyishBrown)
        self.hourLabel.text = transactionViewModel.createdAt?.getHourAndMinutes()
    }

    private func setAsCancelled(transactionViewModel: TransactionViewModel) {
        self.amountLabel.attributedText = transactionViewModel.amount.toCurrency().strikedThrough()
        self.amountLabel.textColor = Color.pinkishGrey
        self.statusLabel.text = "DESCARTADO"
        self.statusLabel.textColor = Color.greyishBrown
        self.statusImageView.image = #imageLiteral(resourceName: "icCancelled").tintImage(color: Color.greyishBrown)
        self.closedHourLabel.text = transactionViewModel.cancelledAt?.getHourAndMinutes()
        self.closedHourLabel.textColor = Color.greyishBrown
        self.hourLabel.text = transactionViewModel.createdAt?.getRelativeDateAndTime()
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

    // Yep, we could refactor this to methods ;)
    private func setInteraction() {
        guard let transactionViewModel = transactionViewModel else { return }
        if let interactionViewModel = transactionViewModel.getLastInteraction() {
            self.reminderIconImage.isHidden = true
            self.numberOfRemindersSentStackView.isHidden = true
            self.hideAddInteractionStackView()
            switch transactionViewModel.getTransactionStatus() {
            case .completed:
                if interactionViewModel.interaction.type == InteractionType.paymentReactionInteraction.rawValue {
                    self.showReactionInformation(interactionViewModel)
                } else {
                    self.interactionStackView.isHidden = true
                    self.showAddInteractionStackView()
                }
            case .cancelled:
                 self.interactionStackView.isHidden = true
            case .pending:
                self.reminderIconImage.isHidden = false
                if let lastTransactionInteraction = transactionViewModel.getLastTransactionInteraction(), let remindersRemaining = lastTransactionInteraction.triesRemaining.value {
                    self.numberOfRemindersSentStackView.isHidden = false
                    self.maximumRemindersLabel.text = "3"
                    self.remindersSentLabel.text = "\(3 - remindersRemaining)"
                    if  remindersRemaining > 0 {
                        self.remindButton?.setAsActive()
                        self.remindButton?.setTitleColor(UIColor.white, for: .normal)
                        self.remindButton?.layer.borderColor = UIColor.clear.cgColor
                    } else {
                        self.remindButton?.setAsInactive()
                        self.remindButton?.setTitleColor(Color.pinkishGrey, for: .disabled)
                        self.remindButton?.layer.borderColor = Color.pinkishGrey.cgColor
                    }
                }
                fallthrough
            default:
                self.showReactionInformation(interactionViewModel)
            }
        } else {
            self.interactionStackView.isHidden = true
            switch transactionViewModel.getTransactionStatus() {
            case .completed:
                self.showAddInteractionStackView()
            case .pending:
                self.remindButton?.setAsActive()
                self.remindButton?.setTitleColor(UIColor.white, for: .normal)
                self.remindButton?.layer.borderColor = UIColor.clear.cgColor
                fallthrough
            default:
                self.hideAddInteractionStackView()
            }
        }
    }

    private func showReactionInformation(_ interactionViewModel: InteractionViewModel) {
        self.interactionStackView.isHidden = false
        self.interactionLabel.text = interactionViewModel.message
        if let imageUrl = interactionViewModel.imageUrl {
            self.interactionImageView.image = UIImage(urlString: imageUrl.absoluteString)
        }
    }

    private func showAddInteractionStackView() {
        self.addInteractionButton.isHidden = false
        self.addInteractionHeightConstraint.priority = UILayoutPriority(rawValue: 250)
    }

    private func hideAddInteractionStackView() {
        self.addInteractionButton.isHidden = true
        self.addInteractionHeightConstraint.priority = UILayoutPriority(rawValue: 999)
    }

    // MARK: - Actions
    @IBAction func cancelActionPressed(_ sender: Any) {
        self.delegate?.requestCanceled(cell: self)
    }

    @IBAction func remindActionPressed(_ sender: Any) {
        self.openInteractionsDelegate?.remindTo(cell: self)
    }

    @IBAction func addInteractionActionPressed(_ sender: Any) {
        self.openInteractionsDelegate?.reactTo(requestCell: self)
    }
}
