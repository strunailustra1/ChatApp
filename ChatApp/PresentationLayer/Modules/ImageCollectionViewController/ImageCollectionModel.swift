//
//  ImageCollectionModel.swift
//  ChatApp
//
//  Created by Наталья Мирная on 19.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

struct ImageCollectionCellModel {
    let imageUrl: String?
}

protocol ImageCollectionModelProtocol: class {
    var delegate: ImageCollectionModelDelegate? { get set }
    func searchImages(by query: String)
}

protocol ImageCollectionModelDelegate: class {
    func setup(images: [ImageCollectionCellModel])
}

class ImageCollectionModel: ImageCollectionModelProtocol {
    
    weak var delegate: ImageCollectionModelDelegate?
    
    let pixabayService: PixabayServiceProtocol
    
    init(pixabayService: PixabayServiceProtocol) {
        self.pixabayService = pixabayService
    }
    
    func searchImages(by query: String) {
        pixabayService.searchImages(searchQuery: query, completionHandler: { [weak self] (images, error) in
            if let images = images {
                let models = images.map({ ImageCollectionCellModel(imageUrl: $0.webformatURL) })
                self?.delegate?.setup(images: models)
            } else if let error = error {
                print(error)
            }
        })
    }
}
