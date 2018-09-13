//
//  ProfileRepository.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/25/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class ProfileRepository: ProfileRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: ProfileErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: ProfileErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func updateProfile(userInformation: UserProfile, onSuccess: @escaping (UserProfileResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(ProfileService.register(parameters: userInformation.toParams()), onSuccess: { networkResponse in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let userProfileResponse = try UserProfileResponse.create(from: networkResponse.body!)
                    onSuccess(userProfileResponse)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (errorResponse) in
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    internal func uploadImage(image: Data, onSuccess: @escaping (ImageUploadResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            apiService?.uploadImage(ProfileService.upload, image: image, onSuccess: { (networkResponse) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let imageRespose = try ImageUploadResponse.create(from: networkResponse.body!)
                    onSuccess(imageRespose)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    //swiftlint:disable:next force_unwrapping
                    onFailure((self.errorParser?.getError(error: error))!)
                }

            }, onError: { (errorResponse) in
                //swiftlint:disable:next force_unwrapping
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        }
    }

    func isUsersMailValidated(response: (Bool) -> Void) {
        response(AccountManager.sharedInstance.getIsMailValidated())
    }

    func validateMail(onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.request(EmailVerificationService.request, onSuccess: { _ in
            onSuccess()
        }, onError: { errorResponse in
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(networkError: errorResponse))!)
        })
    }
}
