//
//  TransactionsOperation.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/23/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class NetworkOperation: AsyncOperation {

    var apiService: APIServiceProtocol?
    var service: Service
    var onSuccess: ((NetworkResponse) -> Void)
    var onError: ((NetworkError) -> Void)

    init(apiService: APIServiceProtocol?, service: Service, onSuccess: @escaping (NetworkResponse) -> Void, onError: @escaping (NetworkError) -> Void) {
        self.apiService = apiService
        self.service = service
        self.onSuccess = onSuccess
        self.onError = onError
        super.init()
    }

    private func executeRequest(service: Service, onSuccess: @escaping (NetworkResponse) -> Void, onError: @escaping (NetworkError) -> Void) {
        apiService?.request(service, onSuccess: { response in
            onSuccess(response)
        }, onError: { errorResponse in
            onError(errorResponse)
        })
    }

    override func main() {
        executeRequest(service: service, onSuccess: { response in
            self.state = .Finished
            self.onSuccess(response)
        }, onError: { error in
            self.state = .Finished
            self.onError(error)
        })
    }
}
