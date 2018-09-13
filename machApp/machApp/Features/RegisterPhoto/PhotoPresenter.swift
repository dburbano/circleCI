//
//  PhotoPresenter.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class PhotoPresenter: PhotoPresenterProtocol {

    weak var view: PhotoViewProtocol?
    var repository: PhotoRepositoryProtocol?

    var imageData: Data?

    required init(repository: PhotoRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: PhotoViewProtocol) {
        self.view = view
    }

    internal func uploadProfileImage() {
        self.view?.selectButton()
        guard let image = imageData else { return }
        UserPhotoManager.sharedInstance.saveProfileImage(imageData: image)
        self.repository?.uploadImage(image: image, onSuccess: {
            print ("Imagen subida con exito")
        }, onFailure: { (uploadError) in
            self.handle(error: uploadError)
        })
    }

    internal func skipForNow() {
        self.view?.navigateToVerifyUser()
    }

    func imageChosen(data: Data?) {
        self.view?.enableButton()
        self.imageData = data
    }

    private func handle(error apiError: ApiError) {
        self.view?.enableButton()
        switch apiError {
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let uploadImageError):
            guard let uploadImageError = uploadImageError as? UploadImageError else { return }
            self.view?.showServerError()
            switch uploadImageError {
            case .uploadImageFailed:
                break
            }
        case .clientError(let uploadImageError):
            guard let uploadImageError = uploadImageError as? UploadImageError else { return }
            self.view?.showServerError()
            switch uploadImageError {
            case .uploadImageFailed:
                break
            }
        default:
            break
        }
    }

}
