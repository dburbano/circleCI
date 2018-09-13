//
//  RealmManager.swift
//  machApp
//
//  Created by lukas burns on 6/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift
import KeychainSwift

class RealmManager {

    static let dataEncryptionKey: String = "DATA_ENCRYPTION_KEY"

    static let sharedInstance: RealmManager = RealmManager()

    static func getRealmConfiguration() -> Realm.Configuration {
//        if let key = RealmManager.getEncryptionKey() {
//            let encryptionConfiguration = Realm.Configuration(encryptionKey: key)
//            return encryptionConfiguration
//        } else {
//            let key = RealmManager.generateAndSaveEncryptionKey()
//            let encryptionConfiguration = Realm.Configuration(encryptionKey: key)
//            return encryptionConfiguration
//        }
        return Realm.Configuration.defaultConfiguration
    }

    static func generateAndSaveEncryptionKey() -> Data {
        let keychain = KeychainSwift()
        var key = Data(count: 64)
        _ = key.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 64, bytes)
        }
        keychain.set(key, forKey: RealmManager.dataEncryptionKey)
        return key
    }

    static func getEncryptionKey() -> Data? {
        let keychain = KeychainSwift()
        let keyData = keychain.getData(RealmManager.dataEncryptionKey)
        if let key = keyData {
            return key
        }
        return nil
    }

    static func executeMigration() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 10,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    for reaction in getInitialInteractions() {
                        migration.create(Interaction.className(), value: reaction)
                    }
                }
                if oldSchemaVersion == 2 { // Arreglo de texto de interacción para schema 2
                    migration.enumerateObjects(ofType: Interaction.className(), { (oldObject, newObject) in
                        if oldObject!["id"] as! String == "rejection_4" {
                            newObject!["message"] = "Rechazo sin dar motivo"
                        }
                    })
                }
                if oldSchemaVersion == 3 {
                    migration.enumerateObjects(ofType: Interaction.className(), { (oldObject, newObject) in
                        if oldObject!["id"] as! String == "reaction_3" {
                            newObject!["message"] = "¡Qué rápido!"
                        }
                    })
                }
                if oldSchemaVersion == 4 {
                    migration.enumerateObjects(ofType: User.className(), { (_, newObject) in
                        if let object = newObject {
                            object["emailConfirmedAt"] = nil
                        }
                    })
                }
                if oldSchemaVersion == 5 {
                    migration.enumerateObjects(
                        ofType: MachTeamConfiguration.className(), { (_, newObject) in
                            if let object = newObject {
                                object["maxContactsForGroup"] = 15
                            }
                        }
                    )
                }
                if oldSchemaVersion == 6 {
                    migration.enumerateObjects(
                        ofType: MachTeamConfiguration.className(), { (_, newObject) in
                            if let object = newObject {
                                object["updateFacePhiPeriodicity"] = 60 * 24
                            }
                    }
                    )
                }
                if oldSchemaVersion == 7 {
                    migration.enumerateObjects(ofType: PrepaidCard.className(), { (_, newObject) in
                        if let object = newObject {
                            object["state"] = nil
                        }
                    })
                }
                if oldSchemaVersion < 9 {
                    migration.enumerateObjects(ofType: MachMessage.className(), { (_, newObject) in
                        if let object = newObject {
                            object["type"] = TeamMachMessageTypes.info.rawValue
                            object["updatedAt"] = object["createdAt"]
                        }
                    })
                }
                if oldSchemaVersion < 10 {
                    migration.enumerateObjects( ofType: MachTeamConfiguration.className(), { (_, newObject) in
                    })
                }
        })
    }

    static func createSeedReactions() {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            for reaction in getInitialInteractions() {
                try realm.write {
                    realm.add(reaction, update: true)
                }
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    static func getInitialInteractions() -> [Interaction] {
        let reactions = RealmManager.sharedInstance.getInitialReactions()
        let rejections = RealmManager.sharedInstance.getInitialRejections()
        let reminders = RealmManager.sharedInstance.getInitialReminders()
        let interactions: [Interaction] = reactions + rejections + reminders
        return interactions
    }

    private func getInitialReactions() -> [Interaction] {
        _ = AssetManager.createLocalUrl(forImageNamed: "reaction_1")
        _ = AssetManager.createLocalUrl(forImageNamed: "reaction_2")
        _ = AssetManager.createLocalUrl(forImageNamed: "reaction_3")
        _ = AssetManager.createLocalUrl(forImageNamed: "reaction_4")

        let reaction1 = Interaction(id: "reaction_1", imageUri: "reaction_1", message: "Recibido, ¡gracias!", type: InteractionType.paymentReactionInteraction.rawValue)
        let reaction2 = Interaction(id: "reaction_2", imageUri: "reaction_2", message: "¡Dinero $$$!", type: InteractionType.paymentReactionInteraction.rawValue)
        let reaction3 = Interaction(id: "reaction_3", imageUri: "reaction_3", message: "¡Qué rápido!", type: InteractionType.paymentReactionInteraction.rawValue)
        let reaction4 = Interaction(id: "reaction_4", imageUri: "reaction_4", message: "¡Lo pasamos bien!", type: InteractionType.paymentReactionInteraction.rawValue)
        return [reaction1, reaction2, reaction3, reaction4]
    }

    private func getInitialReminders() -> [Interaction] {
        _ = AssetManager.createLocalUrl(forImageNamed: "reminder_1")
        _ = AssetManager.createLocalUrl(forImageNamed: "reminder_2")
        _ = AssetManager.createLocalUrl(forImageNamed: "reminder_3")
        _ = AssetManager.createLocalUrl(forImageNamed: "reminder_4")

        let reminder1 = Interaction(id: "reminder_1", imageUri: "reminder_1", message: "Necesito las lucas", type: InteractionType.requestReminderInteraction.rawValue)
        let reminder2 = Interaction(id: "reminder_2", imageUri: "reminder_2", message: "No te olvides de mí...", type: InteractionType.requestReminderInteraction.rawValue)
        let reminder3 = Interaction(id: "reminder_3", imageUri: "reminder_3", message: "Ya esperé bastante", type: InteractionType.requestReminderInteraction.rawValue)
        let reminder4 = Interaction(id: "reminder_4", imageUri: "reminder_4", message: "Recuerda pagar", type: InteractionType.requestReminderInteraction.rawValue)
         return [reminder1, reminder2, reminder3, reminder4]
    }

    private func getInitialRejections() -> [Interaction] {
        _ = AssetManager.createLocalUrl(forImageNamed: "rejection_1")
        _ = AssetManager.createLocalUrl(forImageNamed: "rejection_2")
        _ = AssetManager.createLocalUrl(forImageNamed: "rejection_3")
        _ = AssetManager.createLocalUrl(forImageNamed: "rejection_4")

        let rejection1 = Interaction(id: "rejection_1", imageUri: "rejection_1", message: "No recuerdo esto", type: InteractionType.requestRejectionInteraction.rawValue)
        let rejection2 = Interaction(id: "rejection_2", imageUri: "rejection_2", message: "El monto no corresponde", type: InteractionType.requestRejectionInteraction.rawValue)
        let rejection3 = Interaction(id: "rejection_3", imageUri: "rejection_3", message: "Esto ya lo pagué", type: InteractionType.requestRejectionInteraction.rawValue)
        let rejection4 = Interaction(id: "rejection_4", imageUri: "rejection_4", message: "Rechazo sin dar motivo", type: InteractionType.requestRejectionInteraction.rawValue)
        return [rejection1, rejection2, rejection3, rejection4]
    }
}

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}
