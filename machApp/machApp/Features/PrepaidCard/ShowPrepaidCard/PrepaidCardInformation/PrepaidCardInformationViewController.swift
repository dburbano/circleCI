//
//  PrepaidCardInformationViewController.swift
//  machApp
//
//  Created by Lukas Burns on 7/31/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import UIKit

class PrepaidCardInformationViewController: BaseViewController {
    
    // MARK: - Constants
    
    // MARK: - Variables
    var presenter: PrepaidCardInformationPresenterProtocol?
    
    var prepaidCard: PrepaidCard?
    
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var obfuscatedPANLabel: UILabel!
    @IBOutlet weak var cardHolderNameLabel: UILabel!
    @IBOutlet weak var showCardInformationButton: LoadingButton!
    @IBOutlet weak var cvvLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.presenter?.setup(prepaidCard: prepaidCard)
    }

    @IBAction func showCardInformationButtonTapped(_ sender: Any) {
        self.presenter?.showOrHidePrepaidCardInformation()
    }

}

extension PrepaidCardInformationViewController: PrepaidCardInformationViewProtocol {
    
    func setCVV(digits: String) {
        self.cvvLabel?.text = digits
    }
    func setCardHolderName(name: String) {
        self.cardHolderNameLabel?.text = name
    }
    
    func setExpirationDate(date: String) {
        self.expirationDateLabel?.text = date
    }
    
    func setPAN(digits: String) {
        let attributedString = NSMutableAttributedString(string: digits.separate(every: 4, with: " "))
        attributedString.addAttribute(NSAttributedStringKey.kern, value: 0.8, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Nunito-Bold", size: 24.0) as Any, range: NSRange(location: 0, length: attributedString.length))
        self.obfuscatedPANLabel?.attributedText = attributedString
    }
    
    func setSeeCardDetailButtonText(text: String) {
        self.showCardInformationButton?.setAsActive()
        self.showCardInformationButton?.setTitle(text, for: .normal)
    }
    
    func setHideIconToCardDetailButton() {
        self.showCardInformationButton?.setAsActive()
        self.showCardInformationButton?.setImage(#imageLiteral(resourceName: "iconEyeHidePurple"), for: .normal)
    }
    
    func setShowIconToCardDetailButton() {
        self.showCardInformationButton?.setAsActive()
        self.showCardInformationButton?.setImage(#imageLiteral(resourceName: "icEyeWhite"), for: .normal)
    }
    
    func setSeeCardDetailButtonAsLoading() {
        self.showCardInformationButton?.setImage(nil, for: .normal)
        self.showCardInformationButton?.setAsLoading()
    }
    
    func presentPasscode(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void, with text: String) {
        
    }

    func showNoInternetConnectionError() {
        
    }

    func showServerError() {
        
    }
}
