//
//  ResponseCache.swift
//  ChatApp
//
//  Created by Наталья Мирная on 20.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

class ResponseCache: ResponseCacheProtocol {
    
    private let urlCache: URLCache
    
    init(urlCache: URLCache) {
        self.urlCache = urlCache
    }
    
    func saveImageToCash(data: Data, response: URLResponse) {
        guard let responseURL = response.url else { return }
        let cachedURLResponse = CachedURLResponse(response: response, data: data)
        urlCache.storeCachedResponse(cachedURLResponse, for: URLRequest(url: responseURL))
    }
    
    func getCachedImage(url: URL) -> UIImage? {
        let urlRequest = URLRequest(url: url)
        if let cachedResponse = urlCache.cachedResponse(for: urlRequest) {
            return UIImage(data: cachedResponse.data)
        }
        return nil
    }
}
