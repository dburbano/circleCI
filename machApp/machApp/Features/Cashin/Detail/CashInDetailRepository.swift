//
//  CashInDetailRepository.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/10/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class CashInDetailRepository: CashInDetailRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: CashInErrorParser?
    let tipMessagesArray = ["Por ahora no puedes recargar MACH desde una sucursal física de Bci u otro banco.",
                                "Tu saldo puede demorar hasta 30 minutos en actualizarse después de hacer una recarga.",
                                 "Puedes recargar con transferencia desde cualquier banco nacional.",
                                 "Agrega a MACH como cuenta frecuente en tu banco para hacer las próximas recargas más rápidas.",
                                 "Puedes recargar hasta $500.000 por transferencia electrónica al mes."]

    required init(apiService: APIServiceProtocol?, errorParser: CashInErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }



    internal func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            apiService?.request(AccountService.balance(), onSuccess: { (networkResponse) in
                do {
                    //swiftlint:disable:next force_unwrapping
                    let balanceResponse = try BalanceResponse.create(from: networkResponse.body!)
                    BalanceManager.sharedInstance.save(balance: Balance(balanceResponse: balanceResponse))
                    onSuccess(balanceResponse)
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

    internal func getSavedBalance(response: (Balance?) -> Void) {
        response(BalanceManager.sharedInstance.getBalance())
    }
    
    internal func fetchtipMessage(response: (String) -> Void) {
        let index = Int(arc4random_uniform(UInt32.init(tipMessagesArray.count)))
        let message = tipMessagesArray[index]
        response(message)
    }
}
