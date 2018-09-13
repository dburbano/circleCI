//
//  String+Encryption.swift
//  machApp
//
//  Created by Lukas Burns on 3/13/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

extension String {
    
    private func sha256(_ data: Data) -> Data? {
        guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
        CC_SHA256((data as NSData).bytes, CC_LONG(data.count), res.mutableBytes.assumingMemoryBound(to: UInt8.self))
        return res as Data
    }
    
    func sha256() -> String? {
        guard
            let data = self.data(using: String.Encoding.utf8),
            let shaData = sha256(data)
            else { return nil }
        let rc = shaData.base64EncodedString(options: [])
        return rc
    }
}
