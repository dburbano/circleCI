//
//  ProfileController.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/25/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class ProfileController: BaseViewController {
    // MARK: - Variables
    var presenter: ProfilePresenterProtocol?
    let imagePicker: UIImagePickerController = UIImagePickerController()
    let zendeskArticleName = "filter_editarperfil"
    let mailSegueID = "mailValidationSegue"

    // MARK: - Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameField: BorderTextField!
    @IBOutlet weak var lastNameField: BorderTextField!
    @IBOutlet weak var emailField: BorderTextField!
    @IBOutlet weak var readyButton: LoadingButton!
    @IBOutlet weak var topView: UIView!

    // Validate mail
    @IBOutlet weak var waitLabel: UILabel!
    @IBOutlet weak var alreadyTakenMailLabel: BorderLabel!
    @IBOutlet weak var saferAccountLabel: UILabel!
    @IBOutlet weak var requestMailStack: UIStackView!
    @IBOutlet weak var requestMailButton: UIButton!
    @IBOutlet weak var profileValidatedIconImage: UIImageView!

    @IBOutlet var validationCollection: [UIView]!

    @IBOutlet weak var scrollView: UIScrollView!
    var activeField: UITextField?

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.setupUser()
        setupFields()
        setupAvatar()
        imagePicker.delegate = self
        presenter?.isUsersMailValidated()
        self.readyButton?.setAsInactive()
        registerForKeyboardNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topView.setMachGradient()
        self.nameField.setupView()
        self.lastNameField.setupView()
        self.emailField.setupView()
    }

    deinit {
        deregisterFromKeyboardNotifications()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Private
    private func setupFields() {
        nameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
    }

    private func setupAvatar() {
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: (#selector(ProfileController.avatarImageTapped))))
    }

    @IBAction func firstNameEdited(_ sender: Any) {
        self.presenter?.firstNameChanged(firstName: nameField.text)
    }

    @IBAction func lastNameEdited(_ sender: Any) {
        self.presenter?.lastNameChanged(lastName: lastNameField.text)
    }

    @IBAction func emailEdited(_ sender: Any) {
        self.presenter?.emailChanged(email: emailField.text)
    }

    // MARK: - Actions
    @IBAction func backTapped(_ sender: Any) {
        self.popVC()
    }

    @IBAction func readyTapped(_ sender: Any) {
        presenter?.didPressSave()
    }

    @IBAction func validateMailTapped(_ sender: Any) {
        presenter?.validateEmail()
    }

    @IBAction func helpTapped(_ sender: Any) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().helpbox, helpTagAccessed: self.zendeskArticleName).track()
    }

    @objc func avatarImageTapped() {
        changePicture()
    }

    // MARK: - Actions sheet
    func changePicture() {
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
                self?.presentImagePickerController(sourceType: .camera)
            }))
        }

        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            self?.presentImagePickerController(sourceType: .photoLibrary)
        }))

        actionSheet.addAction(UIAlertAction(title: "Saved Photos Album", style: .default, handler: { [weak self] _ in
            self?.presentImagePickerController(sourceType: .savedPhotosAlbum)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        presentAlertController(alert: actionSheet, animated: true, completion: nil)
    }

    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {}

    // MARK: - Custom Actions
    private func presentImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        setupImagePicker(sourceType: sourceType)
        present(imagePicker, animated: true, completion: nil)
    }

    private func setupImagePicker(sourceType: UIImagePickerControllerSourceType) {
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        if sourceType == .camera {
            imagePicker.showsCameraControls = true
            imagePicker.cameraFlashMode = .off
            imagePicker.cameraCaptureMode = .photo
            imagePicker.cameraDevice = .front
        }
    }

    // MARK: - TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailField {
            let maxLength = 70
            // swiftlint:disable:next force_unwrapping
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else {
            let characterSet = CharacterSet(charactersIn: "abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLKMNÑOPQRSTUVWXYZ áéíóúüäëïöüçÇàèìòùâêîôûÀÈÌÒÛÂÊÎÔÛÿŸ-")
            if string.rangeOfCharacter(from: characterSet.inverted) != nil {
                return false
            }
            let maxLength = 20
            // swiftlint:disable:next force_unwrapping
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
    }

    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            emailField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == mailSegueID, let destinationVC = segue.destination as? MailOverlayViewController {
            destinationVC.delegate = self
        }
    }
}

// MARK: - View Protocol
extension ProfileController: ProfileViewProtocol {
    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }

    internal func navigateBackToMore() {
        self.popVC()
    }

    internal func enableReadyButton() {
        if !self.readyButton.isEnabled {
            self.readyButton.setAsActive()
            self.readyButton.bloatOnce()
        }
    }

    internal func setFirstName(firstName: String?) {
        self.nameField.text = firstName
    }

    internal func setLastName(lastName: String?) {
        self.lastNameField.text = lastName
    }

    internal func setEmail(email: String?) {
        self.emailField.text = email
    }

    internal func setImage(image: UIImage?, imageURL: URL?, placeholderImage: UIImage?) {
        if let image = image {
            self.profileImage.image = image
        } else {
            self.profileImage.sd_setImage(with: imageURL, placeholderImage: placeholderImage)
        }
    }

    internal func disableReadyButton() {
        self.readyButton.setAsInactive()
    }

    internal func selectReadyButton() {
        self.readyButton.setAsLoading()
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    func showValidatedMail(with status: ValidateMailStages) {
        //Hide everything
        hideValidationViews()

        switch status {
        case .validated:
            profileValidatedIconImage?.isHidden = false
        case .notValidated:
            saferAccountLabel?.isHidden = false
            requestMailStack?.isHidden = false
            requestMailButton?.isEnabled = true
            requestMailButton?.isHidden = false
        case .validationInProgress:
            waitLabel?.isHidden = false
        case .takenEmail:
            alreadyTakenMailLabel?.isHidden = false
            requestMailStack?.isHidden = false
            requestMailButton?.isHidden = false
            requestMailButton?.isEnabled = false
        case .blankState:
            break
        }
    }

    private func hideValidationViews() {
        validationCollection?.forEach {
            $0.isHidden = true
        }
    }
    
    func showMailUpdateOverlay() {
        performSegue(withIdentifier: mailSegueID, sender: nil)
    }
}

extension ProfileController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if var pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImage = pickedImage.fixOrientation()
            self.profileImage.image = pickedImage
            let compressedImage = pickedImage.compressTo(5)
            self.presenter?.imageChosen(data: compressedImage)
        }
        dismissVC(completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissVC(completion: nil)
    }
}

// MARK: Keyboard
extension ProfileController {

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let kbSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size,
            let field = activeField else { return }
        
        let contentInsets: UIEdgeInsets =  UIEdgeInsets.init(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect = view.frame
        aRect.size.height -= kbSize.height
        if !aRect.contains(field.convert(field.origin, to: view)) {
            scrollView.scrollRectToVisible(field.frame, animated: true)
        }
    }

    @objc func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        let offset = CGPoint(x: -scrollView.contentInset.left, y: -scrollView.contentInset.top)
        scrollView.setContentOffset(offset, animated: true)
    }
}

extension ProfileController: MailOverlayDelegate {
    func didPressDoNotChangeMail() {
        presenter?.setupUser()
        showValidatedMail(with: .validated)
        disableReadyButton()
    }

    func didPressChangeMail() {
        self.presenter?.uploadProfileImage()
        self.presenter?.updateProfile()
    }
}
