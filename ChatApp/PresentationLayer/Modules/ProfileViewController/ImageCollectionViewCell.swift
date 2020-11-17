//
//  ImageCollectionViewCell.swift
//  ChatApp
//
//  Created by Наталья Мирная on 16.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: ImageView!
    
    func configure(with image: ApiImage) {
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "placeholder")
        imageView.fetchImage(from: image.webformatURL)
    }
}
