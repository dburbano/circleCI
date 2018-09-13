//
//  PhotoRepository.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class PhotoRepository: PhotoRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: UploadImageErrorParser?

    required init(apiService: APIServiceProtocol?) {
        self.apiService = apiService
    }

    internal func uploadImage(image: Data, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.uploadImage(ProfileService.upload, image: image, onSuccess: { (_) in
            onSuccess()
            print("image uploaded ;DDD")
        }, onError: { (errorResponse) in
            if let error = self.errorParser?.getError(networkError: errorResponse) {
                onFailure(error)
            }
        })
    }
}
