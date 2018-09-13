//
//  PhotoViewController.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class PhotoViewController: BaseViewController {

    // MARK: - Constants
    internal let showVerifyUser: String = "showVerifyUser"

    // MARK: - Variables
    var presenter: PhotoPresenterProtocol?
    var imagePicker: UIImagePickerController = UIImagePickerController()

    var name: String!
    var lastName: String!
    var source: String!

    // MARK: - Outlets
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var continueButton: LoadingButton!
    @IBOutlet weak var skipLabel: UIButton!
    @IBOutlet weak var progressBar: ProgressBarView!

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.imagePicker.delegate = self
        self.continueButton.setAsInactive()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressBar.progressToNextStep()
    }

    func setupView() {
        hideNavigationBar(animated: false)
        welcomeLabel.text = "¡Hola " + name + "!"
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    // MARK: - Actions
    @IBAction func continueTapped(_ sender: Any) {
        presenter?.uploadProfileImage()
        navigateToVerifyUser()
    }

    @IBAction func profileImageTapped(_ sender: Any) {
        changePicture()
    }

    @IBAction func skipForNow(_ sender: Any) {
        self.presenter?.skipForNow()
    }

    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showVerifyUser, let destinationVC = segue.destination as? VerifyUserViewController {
            destinationVC.accountMode = AccountMode.create
        }
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

    // MARK: - Private
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
}

// MARK: - View Protocol
extension PhotoViewController: PhotoViewProtocol {

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }

    internal func navigateToVerifyUser() {
        performSegue(withIdentifier: self.showVerifyUser, sender: self)
    }

    internal func enableButton() {
        self.continueButton.setBackgroundColor(UIColor.white, forState: .disabled)
        if !self.continueButton.isEnabled {
            self.continueButton.setAsActive()
            self.continueButton.bloatOnce()
        }
    }

    internal func disableButton() {
        self.continueButton.setAsInactive()
    }

    internal func selectButton() {
        self.continueButton.setAsLoading()
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }
}

extension PhotoViewController: UIImagePickerControllerDelegate {

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
