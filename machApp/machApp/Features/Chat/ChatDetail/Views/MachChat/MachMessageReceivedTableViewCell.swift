//
//  File.swift
//  machApp
//
//  Created by lukas burns on 8/11/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class MachMessageReceivedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userInteractedImageView: UIImageView!
    @IBOutlet weak var messageTitleLabel: UILabel!
    @IBOutlet weak var messageDescriptionLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var lineMessageType: UIView!

    var machMessageViewModel: MachMessageViewModel?
    
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
        let nibName = "MachMessageReceivedTableViewCell"
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func setupCellWith(machMessageViewModel: MachMessageViewModel) {
        self.machMessageViewModel = machMessageViewModel
        self.setUserInteractedImage()
        self.setAmount()
        self.setTitle()
        self.setMessage()
        self.setTime()
        self.setMessageTypeColor()
    }

    private func setUserInteractedImage() {
        if let machMessageViewModel = machMessageViewModel, let imageUrl = machMessageViewModel.fromUser?.profileImageUrl {
            self.userInteractedImageView.sd_setImage(with: imageUrl, placeholderImage: machMessageViewModel.fromUser?.profileImage)
        } else {
            self.userInteractedImageView.image = machMessageViewModel?.fromUser?.profileImage
        }
    }

    private func setAmount() {
        // To be implemented in future mach Messages
    }

    private func setTitle() {
        self.messageTitleLabel?.text = machMessageViewModel?.title
    }

    private func setMessage() {
        self.messageDescriptionLabel?.text = machMessageViewModel?.message
    }

    private func setTime() {
        self.hourLabel.text = machMessageViewModel?.createdAt?.getHourAndMinutes()
    }

    private func setMessageTypeColor() {
        if let type = self.machMessageViewModel?.machMessage.getMessageType() {
            switch type {
            case .info:
                self.lineMessageType.isHidden = true
                self.messageTitleLabel?.textColor = Color.greyishBrown
            case .success:
                self.lineMessageType.backgroundColor = Color.aquamarine
                self.messageTitleLabel?.textColor = Color.greyishBrown
                self.lineMessageType.isHidden = false
            case .warning:
                self.lineMessageType.backgroundColor = UIColor.init(r: 255, g: 153, b: 0)
                self.messageTitleLabel?.textColor = Color.greyishBrown
                self.lineMessageType.isHidden = false
            case .danger:
                self.lineMessageType.backgroundColor = Color.redOrange
                self.messageTitleLabel?.textColor = Color.redOrange
                self.lineMessageType.isHidden = false
            }
        }
    }
}
