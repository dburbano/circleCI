//
//  HomeTableViewCell.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import SDWebImage

@IBDesignable
class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastChatMessageLabel: UILabel!
    @IBOutlet weak var lastChatMessageDateLabel: UILabel!
    @IBOutlet weak var unseenChatMessagesLabel: UILabel!
    @IBOutlet weak var pendingTransactionsImage: UIImageView!
    @IBOutlet weak var nearTransactionImageView: UIImageView!
    @IBOutlet weak var interactionImageView: UIImageView!

    @IBOutlet weak var youLabel: UILabel!
    var lastChatMessage: ChatMessageBaseViewModel?
    var userViewModel: UserViewModel?
    var groupViewModel: GroupViewModel?

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
        let nibName = "HomeTableViewCell"
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func setupCellWith(groupViewModel: GroupViewModel) {
        self.groupViewModel = groupViewModel
        self.userViewModel = groupViewModel.users.first
        self.lastChatMessage = groupViewModel.getLastChatMessage()
        self.setUserName()
        self.setUserProfileImage()
        self.setMessage()
        self.setDate()
        self.setUnseenIcon()
        self.setPendingTransactionsIcon()
        self.setNearTransactionIcon()
        self.setUnseenIconColor()
    }

    private func setUserName() {
        guard let userViewModel = userViewModel else { return }
        if lastChatMessage as? TransactionViewModel != nil {
            if !userViewModel.isInContacts, let lastTransaction = groupViewModel?.getLastChatMessage() as? TransactionViewModel, lastTransaction.wasTransactionOriginatedByProximity() || ((groupViewModel?.getLastChatMessage() as? MachMessageViewModel) != nil) {
                self.firstNameLabel.text = userViewModel.machFirstName
                self.lastNameLabel.text = userViewModel.machLastName
            } else {
                self.firstNameLabel.text = userViewModel.firstNameToShow
                self.lastNameLabel.text = userViewModel.lastNameToShow
            }
        } else if lastChatMessage as? MachMessageViewModel != nil {
            self.firstNameLabel.text = userViewModel.machFirstName
            self.lastNameLabel.text = userViewModel.machLastName
        }
    }

    private func setUserProfileImage() {
        if let imageUrl = userViewModel?.profileImageUrl {
            self.profileImageView.sd_setImage(with: imageUrl, placeholderImage: userViewModel?.profileImage)
        } else {
            self.profileImageView.image = userViewModel?.profileImage
        }
    }

    private func setMessage() {
        self.interactionImageView.isHidden = true
        self.youLabel.isHidden = true
        if let lastTransactionViewModel = self.lastChatMessage as? TransactionViewModel, let lastTransactionInteraction = lastTransactionViewModel.getLastTransactionInteraction(), let interaction = lastTransactionInteraction.interaction {
            let interactionViewModel = InteractionViewModel(interaction: interaction)
            self.interactionImageView.isHidden = false
            if let imageUrl = interactionViewModel.imageUrl {
                self.interactionImageView.image = UIImage(urlString: imageUrl.absoluteString)
            }
            self.lastChatMessageLabel.text = lastTransactionInteraction.interaction?.message

            if lastTransactionInteraction.reactedBy == AccountManager.sharedInstance.getMachId() {
                self.youLabel.isHidden = false
                self.lastChatMessageLabel.text = lastTransactionInteraction.interaction?.message
            }
        } else if let lastChatMessage = self.lastChatMessage?.message, !lastChatMessage.isEmpty && !lastChatMessage.isBlank {
            self.lastChatMessageLabel.text = lastChatMessage
        } else if let lastTransactionViewModel = self.lastChatMessage as? TransactionViewModel {
            self.setDefaultMessage(for: lastTransactionViewModel)
        } else {
            // Case if is a mach message and is empty
            self.lastChatMessageLabel?.text = ""
        }
    }

    private func setDefaultMessage(for transactionViewModel: TransactionViewModel) {
        switch transactionViewModel.getTransactionType() {
        case .paymentReceived:
            self.lastChatMessageLabel.text = "Recibiste un pago por \(transactionViewModel.amount.toCurrency())"
        case .paymentSent:
            self.lastChatMessageLabel.text = "Enviaste un pago por \(transactionViewModel.amount.toCurrency())"
        case .requestReceived:
            self.lastChatMessageLabel.text = "Recibiste un cobro por \(transactionViewModel.amount.toCurrency())"
        case .requestSent:
            self.lastChatMessageLabel.text = "Enviaste un cobro por \(transactionViewModel.amount.toCurrency())"
        default:
            break
        }
    }

    private func setDate() {
        if let lastTransanction = lastChatMessage as? TransactionViewModel, let updatedAt = lastTransanction.updatedAt {
             self.lastChatMessageDateLabel.text = updatedAt.getShortAndRelativeStringForDate()
        } else if let date = lastChatMessage?.createdAt {
            self.lastChatMessageDateLabel.text = date.getShortAndRelativeStringForDate()
        }
    }

    private func setUnseenIcon() {
        if let unseenTransactions = groupViewModel?.unseenTransactions(), unseenTransactions > 0 {
            unseenChatMessagesLabel.text = unseenTransactions.toString
            unseenChatMessagesLabel.isHidden = false
        } else {
            unseenChatMessagesLabel.isHidden = true
        }
    }

    private func setUnseenIconColor() {
        if let chatMessage = lastChatMessage as? MachMessageViewModel {
            switch chatMessage.machMessage.getMessageType() {
            case .info:
                unseenChatMessagesLabel?.backgroundColor = Color.violetBlue
                lastChatMessageLabel?.textColor = Color.warmGrey
            case .success:
                unseenChatMessagesLabel?.backgroundColor = Color.aquamarine
                lastChatMessageLabel?.textColor = Color.warmGrey
            case .warning:
                unseenChatMessagesLabel?.backgroundColor = UIColor.init(r: 255, g: 153, b: 0)
                lastChatMessageLabel?.textColor = Color.warmGrey
            case .danger:
                unseenChatMessagesLabel?.backgroundColor = Color.redOrange
                lastChatMessageLabel?.textColor = Color.redOrange
            }
        } else {
            unseenChatMessagesLabel?.backgroundColor = Color.violetBlue
            lastChatMessageLabel?.textColor = Color.warmGrey
        }
    }

    private func setPendingTransactionsIcon() {
        if let groupViewModel = groupViewModel, groupViewModel.hasPendingTransactions() {
            self.pendingTransactionsImage.isHidden = false
        } else {
            self.pendingTransactionsImage.isHidden = true
        }
    }

    private func setNearTransactionIcon() {
        if let lastTransactionViewModel = lastChatMessage as? TransactionViewModel, lastTransactionViewModel.wasTransactionOriginatedByProximity() {
            self.nearTransactionImageView.isHidden = false
        } else {
            self.nearTransactionImageView.isHidden = true
        }
    }
}
