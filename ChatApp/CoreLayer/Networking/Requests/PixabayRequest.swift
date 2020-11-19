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
    
    private let baseUrl = "https://pixabay.com/api/"
    
    private let apiKey: String
    private let searchQuery: String
    private let limit: Int
    
    override var command: String {
        guard let queryEncoded = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else { return "" }
        
        return "\(baseUrl)?key=\(apiKey)&q=\(queryEncoded)&image_type=photo&pretty=true&per_page=\(limit)"
    }
    
    init(apiKey: String, searchQuery: String, limit: Int = 120) {
        self.apiKey = apiKey
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
