//
//  PixabayService.swift
//  ChatApp
//
//  Created by Наталья Мирная on 19.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

protocol PixabayServiceProtocol {
    func searchImages(searchQuery: String, completionHandler: @escaping ([PixabayImage]?, Error?) -> Void)
    func loadImage(from url: String?, completionHandler: @escaping (UIImage?) -> Void)
}

class PixabayService: PixabayServiceProtocol {
    
    let requestSender: RequestSenderProtocol
    let responseCache: ResponseCacheProtocol
    
    init(requestSender: RequestSenderProtocol, responseCache: ResponseCacheProtocol) {
        self.requestSender = requestSender
        self.responseCache = responseCache
    }
    
    func searchImages(searchQuery: String, completionHandler: @escaping ([PixabayImage]?, Error?) -> Void) {
        let requestConfig = RequestFactory.PixabayRequests.searchImagesConfig(searchQuery: searchQuery)
        requestSender.send(requestConfig: requestConfig) { (result: Result<[PixabayImage]?, Error>) in
            switch result {
            case .success(let images):
                completionHandler(images, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func loadImage(from url: String?, completionHandler: @escaping (UIImage?) -> Void) {
        guard let url = url, let imageURL = URL(string: url) else { return }
        
        // Загружаем данные из кэша
        if let image = responseCache.getCachedImage(url: imageURL) {
            completionHandler(image)
            return
        }
        
        let requestConfig = RequestFactory.PixabayRequests.loadImageConfig(imageUrl: url)
        
        // Загрузка изображения из сети
        requestSender.send(requestConfig: requestConfig) { [weak self] (result: Result<PixabayLoadedImage, Error>) in
            switch result {
            case .success(let loadedImage):
                completionHandler(UIImage(data: loadedImage.data))
                
                // Сохранение в кэш
                self?.responseCache.saveImageToCash(data: loadedImage.data, response: loadedImage.urlResponse)
            case .failure(let error):
                print(error)
            }
        }
    }
}
