//
//  ImageView.swift
//  ChatApp
//
//  Created by Наталья Мирная on 16.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

class ImageView: UIImageView {
    func fetchImage(from url: String?) {
        guard let url = url, let imageURL = URL(string: url) else { return }
        
        // Загружаем данные из кэша
        if let image = getCachedImage(url: imageURL) {
            self.image = image
            return
        }
        
        // Загрузка изображения из сети
        NetworkManager.shared.getImage(from: imageURL) { (data, response) in
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
            
            // Сохранение в кэш
            self.saveImageToCash(data: data, response: response)
        }
    }
    
    private func saveImageToCash(data: Data, response: URLResponse) {
        guard let responseURL = response.url else { return }
        let cachedURLResponse = CachedURLResponse(response: response, data: data)
        URLCache.shared.storeCachedResponse(cachedURLResponse, for: URLRequest(url: responseURL))
    }
    
    private func getCachedImage(url: URL) -> UIImage? {
        let urlRequest = URLRequest(url: url)
        if let cachedResponse = URLCache.shared.cachedResponse(for: urlRequest) {
            return UIImage(data: cachedResponse.data)
        }
        return nil
    }
}
