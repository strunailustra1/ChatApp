//
//  PixabayRequest.swift
//  ChatApp
//
//  Created by Наталья Мирная on 18.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

class PixabayRequest: RequestProtocol {
    fileprivate var command: String {
        assertionFailure("Should use a subclass of PixabayRequest ")
        return ""
    }
    
    var urlRequest: URLRequest? {
        if let url = URL(string: command) {
            return URLRequest(url: url)
        }
        
        return nil
    }
}

class PixabaySearchImagesRequest: PixabayRequest {
    
    private let baseUrl = Bundle.main.object(forInfoDictionaryKey: "PixabayApiUrl") as? String
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "PixabayApiKey") as? String
    private let searchQuery: String
    private let limit: Int
    
    override var command: String {
        guard let queryEncoded = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let baseUrl = self.baseUrl,
              let apiKey = self.apiKey
            else { return "" }
        
        return "\(baseUrl)?key=\(apiKey)&q=\(queryEncoded)&image_type=photo&pretty=true&per_page=\(limit)"
    }
    
    init(searchQuery: String, limit: Int = 120) {
        self.searchQuery = searchQuery
        self.limit = limit
    }
}

class PixabayLoadImageRequest: PixabayRequest {
    
    private let imageUrl: String
    
    override var command: String {
        imageUrl
    }
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
    }
}
