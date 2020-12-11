//
//  ImageCollectionViewCell.swift
//  ChatApp
//
//  Created by Наталья Мирная on 16.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    func configure(with image: ImageCollectionCellModel, pixabayService: PixabayServiceProtocol?) {
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "placeholder")
        
        pixabayService?.loadImage(from: image.imageUrl) { (image) in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
}
