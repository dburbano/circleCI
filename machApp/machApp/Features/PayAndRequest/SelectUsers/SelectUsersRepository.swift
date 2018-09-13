//
//  SelectUsersRepository.swift
//  machApp
//
//  Created by lukas burns on 3/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class SelectUsersRepository: SelectUsersRepositoryProtocol {

    var apiService: APIServiceProtocol?
    var errorParser: SelectUsersErrorParser?

    required init(apiService: APIServiceProtocol?, errorParser: SelectUsersErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    func getUsers(onSuccess: @escaping (Results<User>) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let users = realm.objects(User.self).filter("isInContacts = %@ AND machId != %@ AND machId != nil", true, AccountManager.sharedInstance.getMachId() as Any)
            onSuccess(users)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            onFailure((self.errorParser?.getError(error: error))!)
        }
    }

    func getUsersBy(deviceBeacons: [DeviceBeacon], onSuccess: @escaping ([User]) -> Void, onFailure: @escaping (ApiError) -> Void) {
        var users: [User] = []
        var unfoundDevices: [[String: Any]] = []
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            for deviceBeacon in deviceBeacons {
                if let user = realm.objects(User.self).filter("deviceBeacon.minor = %@ AND deviceBeacon.major = %@", deviceBeacon.minor, deviceBeacon.major).first {
                    users.append(user)
                } else {
                    // Call Service
                    try unfoundDevices.append(deviceBeacon.toParams())
                }
            }
            if !users.isEmpty {
                onSuccess(users)
            }
            apiService?.request(ProfileService.nearby(parameters: ["bluetoothIds": unfoundDevices]), onSuccess: { (networkResponse) in
                do {
                    let receivedUsers = try User.createArray(from: networkResponse.body!)
                    users.append(contentsOf: receivedUsers)
                    onSuccess(users)
                } catch {
                    ExceptionManager.sharedInstance.recordError(error)
                }
            }, onError: { (networkError) in
                //onFailure((self.errorParser?.getError(networkError: networkError))!)
            })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            //onFailure((self.errorParser?.getError(error: error))!)
        }
     }

    func getUserBy(deviceBeacon: DeviceBeacon, onSuccess: @escaping (User) -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            if let user = realm.objects(User.self).filter("deviceBeacon.minor = %@ AND deviceBeacon.major = %@", deviceBeacon.minor, deviceBeacon.major).first {
                onSuccess(user)
            } else {
                try apiService?.request(ProfileService.nearby(parameters: deviceBeacon.toParams()), onSuccess: { (networkResponse) in
                    do {
                        let receivedUser = try User.create(from: networkResponse.body!)
                        onSuccess(receivedUser)
                    } catch {
                        ExceptionManager.sharedInstance.recordError(error)
                    }
                }, onError: { (networkError) in
                    //onFailure((self.errorParser?.getError(networkError: networkError))!)
                })
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

}
