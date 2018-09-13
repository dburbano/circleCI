//
//  MachProfileViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/12/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import SDWebImage

protocol MachProfileCellDelegate: class {
    func didPress(cell: MachProfileViewController, with data: MachTeamConfiguration)
}

class MachProfileViewController: UIViewController {

    @IBOutlet weak var tooltipView: BaseTooltipView!
    @IBOutlet weak var machProfileNameLabel: UILabel!
    @IBOutlet weak var machProfileThumbnailImage: UIImageView!
    @IBOutlet weak var accesoryView: UIImageView!

    var isSelected: Bool = false {
        didSet {
            accesoryView.isHidden = !isSelected
        }
    }

    lazy var profile = ConfigurationManager.sharedInstance.getMachTeamConfiguration()
    weak var delegate: MachProfileCellDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let profile = profile else { return }
        machProfileNameLabel.text = profile.name

        if let url = URL(string: profile.smallImageURLString) {
            machProfileThumbnailImage.sd_setImage(with: url, completed: nil)
        }
    }

    // MARK: Actions
    @IBAction func didPressCell(_ sender: Any) {
        tooltipView.isHidden = true
        guard let profile = profile else { return }
        delegate?.didPress(cell: self, with: profile)
    }
}
