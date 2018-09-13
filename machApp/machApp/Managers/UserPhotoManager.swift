//
//  UserPhotoManager.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class UserPhotoManager: NSObject {
    static let sharedInstance: UserPhotoManager = UserPhotoManager()
    static let imageName: String = "profile.png"

    private override init() {
        super.init()
    }

    func saveProfileImage(image: UIImage?) {
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent(UserPhotoManager.imageName)
        if let image = image, let imageData = UIImagePNGRepresentation(image) {
            do {
                try imageData.write(to: imageURL)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
            }
        }
    }

    func saveProfileImage(imageData: Data?) {
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent(UserPhotoManager.imageName)
        if let imageData = imageData {
            do {
                try imageData.write(to: imageURL)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
            }
        }
    }

    func getProfileImage() -> UIImage? {
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent(UserPhotoManager.imageName)
        let profileImage = UIImage(contentsOfFile: imageURL.path)
        return profileImage
    }

    func getProfileImageData() -> Data? {
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent(UserPhotoManager.imageName)
        let profileImage = UIImage(contentsOfFile: imageURL.path)
        if let profileImage = profileImage {
            return UIImagePNGRepresentation(profileImage)
        }
        return nil
    }

    func deleteUserProfileImage() {
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent(UserPhotoManager.imageName)
        do {
            try FileManager.default.removeItem(at: imageURL)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }
}
