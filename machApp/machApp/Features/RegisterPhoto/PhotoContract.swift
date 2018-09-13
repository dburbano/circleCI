//
//  PhotoContract.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol PhotoViewProtocol: BaseViewProtocol {
    func navigateToVerifyUser()
    func enableButton()
    func disableButton()
    func selectButton()
}

protocol PhotoPresenterProtocol: BasePresenterProtocol {
    func uploadProfileImage()
    func skipForNow()
    func setView(view: PhotoViewProtocol)
    func imageChosen(data: Data?)
}

protocol PhotoRepositoryProtocol {
    func uploadImage(image: Data, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void)
}

enum UploadImageError: Error {
    case uploadImageFailed(message: String)
}

class UploadImageErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}
