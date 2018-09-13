//
//  TransferInstructionsViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 4/11/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class TransferInstructionsViewController: BaseViewController {
    
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var firstStepTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFirstStepTitle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        super.viewWillLayoutSubviews()
        topContainer.setMachGradient(includesStatusBar: true, navigationBar: nil, withRoundedBottomCorners: true, withShadow: true)
    }
    
    @IBAction func didPressBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupFirstStepTitle() {
        //We need to do this by code, because attributed strings are incompatible with emojis: Maybe this is a bug of Xcode
        let title = "Ingresa a tu banco. Recuerda que MACH recibe transferencias desde todos los bancos 😎."
        let titleNSString = NSString.init(string: title)
        let attString = NSMutableAttributedString(string: title,
                                                  // swiftlint:disable:next force_unwrapping
            attributes: [NSAttributedStringKey.font: UIFont(name: "Nunito-Regular", size: 16.0)!,
                         NSAttributedStringKey.foregroundColor: Color.greyishBrown])
        let range = titleNSString.range(of: "MACH")
        // swiftlint:disable:next force_unwrapping
        attString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Nunito-Bold", size: 16.0)!, range: range)
        firstStepTitleLabel.attributedText = attString
    }
}
