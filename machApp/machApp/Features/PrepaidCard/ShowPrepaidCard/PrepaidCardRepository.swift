//
//  PrepaidCardRepository.swift
//  machApp
//
//  Created by Lukas Burns on 3/19/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class PrepaidCardRepository: PrepaidCardRepositoryProtocol {
    var apiService: APIServiceProtocol?
    var errorParser: PrepaidCardErrorParser?
    let tipMessagesArray = [
        "Muchos comercios cobran de 1 a 5 USD para validar tu tarjeta. Lo reversan luego de unos días.",
        "Cuando uses tu tarjeta tienes que tener saldo para cubrir la compra. No puedes pagar en cuotas.",
        "Recuerda que tu tarjeta es únicamente para compras en comercios online en el extranjero.",
        "Revisa tus compras en el historial de movimientos. Toca Ver historial desde el home.",
        "Cuando compres elige los precios en dólares y no en pesos. La tasa de cambio suele ser mejor."
    ]
    
    required init(apiService: APIServiceProtocol?, errorParser: PrepaidCardErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    internal func getUSDExchangeRate(onSuccess: @escaping (USDExchangeRateResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.request(CommonService.getUSDExchangeRate(), onSuccess: { (networkResponse) in
            do {
                //swiftlint:disable:next force_unwrapping
                let usdExchangeRateResponse = try USDExchangeRateResponse.create(from: networkResponse.body!)
                onSuccess(usdExchangeRateResponse)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                onFailure((self.errorParser?.getError(error: error))!)
            }
        }, onError: { (networkError) in
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(networkError: networkError))!)
        })
    }
    
    internal func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            apiService?.request(AccountService.balance(), onSuccess: { (networkResponse) in
                do {
                    // swiftlint:disable:next force_unwrapping
                    let balanceResponse = try BalanceResponse.create(from: networkResponse.body!)
                    BalanceManager.sharedInstance.save(balance: Balance(balanceResponse: balanceResponse))
                    onSuccess(balanceResponse)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                    onFailure((self.errorParser?.getError(error: error))!)
                }
            }, onError: { (errorResponse) in
                onFailure((self.errorParser?.getError(networkError: errorResponse))!)
            })
        }
    }

    func getSavedBalance(response: (Balance?) -> Void) {
        response(BalanceManager.sharedInstance.getBalance())
    }

    internal func removePrepaidCard(prepaidCardId: String, onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void) {
        apiService?.request(PrepaidCardService.removePrepaidCard(prepaidCardId: prepaidCardId), onSuccess: { (jsonResponse) in
            onSuccess()
        }, onError: { (error) in
            //swiftlint:disable:next force_unwrapping
            onFailure((self.errorParser?.getError(networkError: error))!)
        })
    } 
    
    func fetchTipMessage(response: (String) -> Void) {
        let index = Int(arc4random_uniform(UInt32.init(tipMessagesArray.count)))
        let message = tipMessagesArray[index]
        response(message)
    }
}
