//
//  ImageComparator.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

protocol ImageComparatorProtocol {
    func isEqualImages(
        leftImage: UIImage?,
        rightImage: UIImage?,
        completion: @escaping(_ isEqualImages: Bool) -> Void
    )
}

class ImageComparator: ImageComparatorProtocol {
    func isEqualImages(
        leftImage: UIImage?,
        rightImage: UIImage?,
        completion: @escaping(_ isEqualImages: Bool) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            var isEqualImages = false
            if let rightImage = rightImage,
                let rightImageData = rightImage.jpegData(compressionQuality: 1) ?? rightImage.pngData() {
                
                if let leftImage = leftImage,
                    let leftImageData = leftImage.jpegData(compressionQuality: 1) ?? leftImage.pngData() {
                    isEqualImages = leftImageData == rightImageData
                }
            } else {
                isEqualImages = leftImage == rightImage
            }
            DispatchQueue.main.async {
                completion(isEqualImages)
            }
        }
    }
}
