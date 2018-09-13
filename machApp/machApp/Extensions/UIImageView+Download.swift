//
//  UIImageView+Download.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadImage (link: String, contentMode: UIViewContentMode) {

        guard
            let url: NSURL = NSURL(string: link)
            else { return }
        self.contentMode = contentMode
        URLSession.shared.dataTask(with: url as URL, completionHandler: {(data, response, error) -> Void in
            guard
                let httpResponse: HTTPURLResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                let mimeType: String = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }

            DispatchQueue.global().async {
                self.image = image
            }
        }).resume()
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}
