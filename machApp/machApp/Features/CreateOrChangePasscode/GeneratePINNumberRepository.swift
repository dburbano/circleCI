//
//  GeneratePINNumberRepository.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class GeneratePINNumberRepository: GeneratePINNumberRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: GeneratePinNumberErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: GeneratePinNumberErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    public func setEncryptedPasscode(passcode: [String]) {
        AccountManager.sharedInstance.setAndEncrypt(passcode: passcode)
    }

    func getOwnProfile(onSuccess: @escaping (UserProfileResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.request(ProfileService.me,
        onSuccess: { (networkResponse) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let userProfileResponse = try UserProfileResponse.create(from: networkResponse.body!)
                    onSuccess(userProfileResponse)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    //swiftlint:disable:next force_unwrapping
                    onFailure((self.errorParser?.getError(error: error))!)
                }
        },
        onError: { (errorResponse) in
            onFailure((self.errorParser?.getError(networkError: errorResponse))!)
        })
    }
}
