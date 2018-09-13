//
//  ReactionRepository.swift
//  machApp
//
//  Created by lukas burns on 10/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class InteractionRepository: InteractionRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: InteractionErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: InteractionErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func getReceivedPaymentInteractions(onSuccess: @escaping (Results<Interaction>) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let interactions = realm.objects(Interaction.self).filter("type = %@", InteractionType.paymentReactionInteraction.rawValue)
            onSuccess(interactions)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    func getRequestRejectedInteractions(onSuccess: @escaping (Results<Interaction>) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let interactions = realm.objects(Interaction.self).filter("type = %@", InteractionType.requestRejectionInteraction.rawValue)
            onSuccess(interactions)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    func getRequestReminderInteractions(onSuccess: @escaping (Results<Interaction>) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let interactions = realm.objects(Interaction.self).filter("type = %@", InteractionType.requestReminderInteraction.rawValue)
            onSuccess(interactions)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }
}
