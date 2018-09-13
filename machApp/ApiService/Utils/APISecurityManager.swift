//
//  APISecurityManager.swift
//  machApp
//
//  Created by lukas burns on 9/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import KeychainSwift
import SwiftyJSON

class APISecurityManager: NSObject {
    static let sharedInstance: APISecurityManager = APISecurityManager()

    static let privateEncriptionKey: String = "PRIVATE_ENCRIPTION_KEY"
    static let cipherKey: String = "CIPHER_KEY"
    static let publicEncriptionKey: String = "PUBLIC_KEY"
    static let serverPublicEncriptionKey: String = "SERVER_PUBLIC_KEY"
    let keychain = KeychainSwift()

    func isCipherKeyPresent() -> Bool {
        return  APISecurityManager.sharedInstance.getCipherKey() != nil
    }

    func createCipherKeyIfNotPresent(shouldForceCreate: Bool = false) {
        let isCipherKeyNotPresent = !isCipherKeyPresent()
        guard isCipherKeyNotPresent || shouldForceCreate else { return }
        APISecurityManager.sharedInstance.generateKeys()
        APISecurityManager.sharedInstance.exchangePublicKeys(onSuccess: { (encriptionPublicKeyResponse) in
            let serverPublicKey = encriptionPublicKeyResponse.publicKey
            APISecurityManager.sharedInstance.set(serverPublicKey: serverPublicKey)
            if let privateKey = APISecurityManager.sharedInstance.getPrivateKey()?.dataFromHexadecimalString(),
                let serverPublicKey = APISecurityManager.sharedInstance.getServerPublicKey()?.dataFromHexadecimalString() {

                guard let sharedSecret = APISecurityManager.sharedInstance.generateCommonSecret(privateKey: privateKey, serverPublicKey: serverPublicKey) else { return }

                let cipherKey = APISecurityManager.sharedInstance.generateCipher(sharedSecret: sharedSecret)
                APISecurityManager.sharedInstance.set(cipherKey: cipherKey)
            }
        }) {
            // Error
        }
    }

    func generateKeys() {
        let keys = try? CC.EC.generateKeyPair(384)
        let privateKey = (keys!.0.hexadecimalString())
        let publicKey = (keys!.1.hexadecimalString())
        APISecurityManager.sharedInstance.set(publicKey: publicKey)
        APISecurityManager.sharedInstance.set(privateKey: privateKey)
    }

    func exchangePublicKeys(onSuccess: @escaping (EncriptionPublicKeyResponse) -> Void, onFailure: @escaping () -> Void) {
        guard let publicKey = APISecurityManager.sharedInstance.getPublicKey() else { return }
        AlamofireNetworkLayer.sharedInstance.request(SecurityService.keys(parameters: ["public_key": publicKey]), onSuccess: { (networkResponse) in
            do {
                //swiftlint:disable:next force_unwrapping
                let publicKeyResponse = try EncriptionPublicKeyResponse.create(from: networkResponse.body!)
                onSuccess(publicKeyResponse)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
                onFailure()
            }
        }) { (networkError) in
            onFailure()
        }
    }

    func generateCommonSecret(privateKey: Data, serverPublicKey: Data) -> Data? {
        let sharedSecret = try? CC.EC.computeSharedSecret(privateKey, publicKey: serverPublicKey)
        return sharedSecret
    }

    func generateCipher(sharedSecret: Data) -> String {
        let shaSecret = CC.digest(sharedSecret, alg: .sha256).hexadecimalString()
        let index = shaSecret.index(shaSecret.startIndex, offsetBy: 16)
        return String(shaSecret[..<index])
    }

    internal func set(privateKey: String) {
        keychain.set(privateKey, forKey: APISecurityManager.privateEncriptionKey)
    }

    internal func set(publicKey: String) {
        keychain.set(publicKey, forKey: APISecurityManager.publicEncriptionKey)
    }

    func set(serverPublicKey: String) {
        keychain.set(serverPublicKey, forKey: APISecurityManager.serverPublicEncriptionKey)
    }

    func set(cipherKey: String) {
        keychain.set(cipherKey, forKey: APISecurityManager.cipherKey)
    }

    func deletePrivateKey() {
        keychain.delete(APISecurityManager.privateEncriptionKey)
    }

    func deletePublicKey() {
        keychain.delete(APISecurityManager.publicEncriptionKey)
    }

    func deleteServerPublicKey() {
        keychain.delete(APISecurityManager.serverPublicEncriptionKey)
    }

    func deleteCipherKey() {
        keychain.delete(APISecurityManager.cipherKey)
    }

    func getPrivateKey() -> String? {
        return keychain.get(APISecurityManager.privateEncriptionKey)
    }

    func getPublicKey() -> String? {
        return keychain.get(APISecurityManager.publicEncriptionKey)
    }

    func getServerPublicKey() -> String? {
        return keychain.get(APISecurityManager.serverPublicEncriptionKey)
    }

    func getCipherKey() -> String? {
        return keychain.get(APISecurityManager.cipherKey)
    }

    func encryptParameters(parameters: [String: Any]) -> [String: Any] {
        let gcmEncription = APISecurityManager.sharedInstance.gcmEncrypt(parameters: parameters)
        return ["content": gcmEncription.0, "tag": gcmEncription.1, "iv": gcmEncription.2]
    }

    func gcmEncrypt(parameters: [String: Any]) -> (String, String, String) {
        let tagLength: Int = 16
        let initializationVector =  APISecurityManager.sharedInstance.generateInitializationVector()
        guard let cipherKey = APISecurityManager.sharedInstance.getCipherKey()?.data(using: .utf8) else { return ("","","") }
        guard let data = try? JSON.init(rawValue: parameters)?.rawString()?.data(using: .utf8) else { return ("","","") }
        let encriptedData = try? CC.GCM.crypt(.encrypt, algorithm: .aes, data: data!, key: cipherKey, iv: initializationVector, aData: Data(), tagLength: tagLength)
        let tag = encriptedData?.1
        let content = encriptedData?.0
        return (content!.hexadecimalString(), (tag?.hexadecimalString())!, initializationVector.hexadecimalString())
    }
    
    func gcmDecrypt(content: String, tag: String, iv: String) -> String? {
        let tagLength: Int = 16
        guard let cipherKey = APISecurityManager.sharedInstance.getCipherKey()?.data(using: .utf8) else { return nil}
        let data = try? CC.GCM.crypt(.decrypt, algorithm: .aes, data: content.dataFromHexadecimalString()!, key: cipherKey, iv: iv.dataFromHexadecimalString()!, aData: Data(), tagLength: tagLength)
        return String.init(data: (data?.0)!, encoding: .utf8) 
    }

    func generateInitializationVector() -> Data {
        let initializationVector = CC.generateRandom(12)
        return initializationVector
    }

}
