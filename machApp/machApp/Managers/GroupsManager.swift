//
//  GroupsManager.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class GroupsManager {

    static let sharedInstance = GroupsManager()

    private init() {}

    func getGroup(with id: String) -> GroupViewModel? {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let predicate = NSPredicate(format: "identifier = %@ ", id)
            guard let group = realm.objects(Group.self).filter(predicate).first else { return nil }
            return GroupViewModel(group: group)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            return nil
        }
    }

}
