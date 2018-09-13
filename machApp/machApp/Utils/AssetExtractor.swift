//
//  AssetExtractor.swift
//  machApp
//
//  Created by lukas burns on 10/24/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class AssetManager {

    static func createLocalUrl(forImageNamed name: String) -> URL? {
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let url = documentDirectory.appendingPathComponent("\(name).png")
        let path = url.path

        guard fileManager.fileExists(atPath: path) else {
            guard
                let image = UIImage(named: name),
                let data = UIImagePNGRepresentation(image)
                else { return nil }
            
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
            return url
        }
        return url
    }
    
    static func getUrlFor(resource name: String) -> URL? {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let url = documentDirectory.appendingPathComponent("\(name).png")
        return url
    }
}
