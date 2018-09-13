//
//  InteractionTableViewCell.swift
//  machApp
//
//  Created by lukas burns on 10/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class InteractionTableViewCell: UITableViewCell {

    var interactionViewModel: InteractionViewModel?
    var interactionTappedDelegate: InteractionTappedDelegate?

    @IBOutlet weak var interactionImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var interactionMessageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.containerView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        } else {
            self.containerView?.backgroundColor = UIColor.white
        }
    }

    @IBAction func cellTouchUpInside(_ sender: Any) {
        self.interactionTappedDelegate?.interactionTapped(cell: self)
    }

    @IBAction func cellDragOutside(_ sender: Any) {
        self.setHighlighted(false, animated: true)
    }

    @IBAction func cellTouchDown(_ sender: Any) {
        self.setHighlighted(true, animated: true)
    }

    @IBAction func touchUpOutside(_ sender: Any) {
        self.setHighlighted(false, animated: true)
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
    }

    func loadViewFromNib() -> UIView? {
        let nibName = "InteractionTableViewCell"
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func setupCell(with interactionViewModel: InteractionViewModel) {
        self.interactionViewModel = interactionViewModel
        self.interactionMessageLabel.text = interactionViewModel.message
        if let imageUrl = interactionViewModel.imageUrl {
            self.interactionImageView.image = UIImage(urlString: imageUrl.absoluteString)
        }
    }

}
