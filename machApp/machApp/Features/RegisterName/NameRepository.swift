//
//  NameRepository.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/21/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class NameRepository: NameRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: RegisterProfileErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: RegisterProfileErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    internal func registerProfile(userInformation: UserProfile, onSuccess: @escaping (UserProfileResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            try apiService?.request(ProfileService.register(parameters: userInformation.toParams()), onSuccess: { (networkResponse) in
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
            onFailure((errorParser?.getError(error: error))!)
        }
    }
}
