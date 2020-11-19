//
//  RequestsFactory.swift
//  ChatApp
//
//  Created by Наталья Мирная on 19.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

struct RequestFactory {
    static let ephemeralNetworkSession = NetworkSession(
        urlSession: URLSession(configuration: URLSessionConfiguration.ephemeral)
    )
    
    struct PixabayRequests {
        
        static func searchImagesConfig(searchQuery: String) -> RequestConfig<PixabaySearchImageParser> {
            let request = PixabaySearchImagesRequest(
                apiKey: "19137210-0a0bbcfeab89161406b938546",
                searchQuery: searchQuery
            )
            
            return RequestConfig<PixabaySearchImageParser>(
                session: RequestFactory.ephemeralNetworkSession,
                request: request,
                parser: PixabaySearchImageParser()
            )
        }

        static func loadImageConfig(imageUrl: String) -> RequestConfig<PixabayLoadImageParser> {
            return RequestConfig<PixabayLoadImageParser>(
                session: RequestFactory.ephemeralNetworkSession,
                request: PixabayLoadImageRequest(imageUrl: imageUrl),
                parser: PixabayLoadImageParser()
            )
        }
    }
}
