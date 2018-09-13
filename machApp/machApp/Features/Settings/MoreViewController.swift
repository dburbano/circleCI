//
//  MoreViewController.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/30/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import SDWebImage

class MoreViewController: BaseViewController {
    // MARK: - Constants
    fileprivate let showProfile: String = "showProfile"
    fileprivate let headerIdentifier: String = "header"
    fileprivate let cellfirstTypeIdentifier: String = "FirstTypeCell"
    fileprivate let sectionHeight: CGFloat = 50.0
    fileprivate let moreTableSegue: String = "moreTableSegue"
    

    // MARK: - Variables
    var presenter: MorePresenterProtocol!
    var shouldPresentShare: Bool?

    // MARK: - Outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var validatedEmailImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfile()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topView.setMachGradient()
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.clipsToBounds = true
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: true)
        self.presenter.setUserInfo()
        self.presenter.isUsersMailValidated()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Navigation
    @IBAction func unwindToMore(segue: UIStoryboardSegue) {
    }
    
    // MARK: - Private
    private func setupView() {
        profileView.clipsToBounds = false
        profileView.layer.shadowColor = UIColor.black.cgColor
        profileView.layer.shadowOpacity = 0.25
        profileView.layer.shadowOffset = CGSize.zero
        profileView.layer.shadowRadius = 2.5
        profileView.layer.shadowPath = UIBezierPath(roundedRect: profileView.bounds, cornerRadius: 7).cgPath
        let shadow = UIImageView(frame: profileView.bounds)
        shadow.clipsToBounds = true
        shadow.layer.cornerRadius = 7
        profileView.addSubview(shadow)
    }

    private func setupProfile() {
        profileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: (#selector(MoreViewController.profileTapped))))
    }

    // MARK: - Behaviours

    @objc func profileTapped() {
        self.presenter?.profileButtonTapped()
    }

    func profileUpdatedMessage() {
        self.showToastWithText(text: "Perfil actualizado!")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == moreTableSegue,
            let destinationVC = segue.destination as? MoreTableViewController {
            destinationVC.shouldPresentShare = shouldPresentShare
            shouldPresentShare = nil
        }
    }
}

// MARK: - View Protocol
extension MoreViewController: MoreViewProtocol {
    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }

    internal func navigateToProfile() {
        performSegue(withIdentifier: showProfile, sender: self)
    }

    internal func navigateToRegister() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let root = storyboard.instantiateViewController(withIdentifier: "TabBarViewController")
        //swiftlint:disable:next force_cast
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = root
    }

    internal func setUserName(userName: String?) {
        self.nameLabel.text = userName
    }

    internal func setEmail(email: String?) {
        self.emailLabel.text = email
    }

    internal func setImage(image: UIImage?, imageURL: URL?, placeholderImage: UIImage?) {
        if let image = image {
            self.profileImage.image = image
        } else {
            self.profileImage.sd_setImage(with: imageURL, placeholderImage: placeholderImage)
        }
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    func showValidatedMail(with image: UIImage) {
        validatedEmailImage?.image = image
    }
}
