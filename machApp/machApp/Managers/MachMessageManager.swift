//
//  MachMessageManager.swift
//  machApp
//
//  Created by lukas burns on 8/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift

class MachMessageManager {
 
    static func handleMachMessageReceived(machMessage: MachMessage) {
        guard machMessage.belongsToUser() else { return }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            if let receivedFromUser = machMessage.fromUser {
                machMessage.fromUser = ContactManager.sharedInstance.upsertUser(receivedUser: receivedFromUser)
            }
            if let destinationGroup = realm.objects(Group.self).first(where: { (group) -> Bool in
                group.identifier == machMessage.groupId
            }) {
                // Group exists
                addMachMessageToExistingGroup(machMessage: machMessage, group: destinationGroup)
            } else {
                // Group doesn't exists
                createNewGroup(for: machMessage)
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            print("Error info: \(error)")
        }
    }

    static func addMachMessageToExistingGroup(machMessage: MachMessage, group: Group) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                try group.appendOrUpdateMachMessage(machMessage)
                group.updateGroupUpdatedAtWith(machMessage)
                realm.add(group, update: true)
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            print("Error info: \(error)")
        }
    }

    static func createNewGroup(for machMessage: MachMessage) {
        guard let groupId = machMessage.groupId else { return }
        let newGroup: Group = Group(identifier: groupId)
        guard let fromUser = machMessage.fromUser else { return }
        newGroup.users.append(fromUser)
        newGroup.machMessages.append(machMessage)
        newGroup.updateGroupUpdatedAtWith(machMessage)
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                realm.add(newGroup, update: true)
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            print("Error info: \(error)")
        }
    }
    
}
