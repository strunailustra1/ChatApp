//
//  PixabayLoadImageParser.swift
//  ChatApp
//
//  Created by Наталья Мирная on 18.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

struct PixabayLoadedImage {
    let data: Data
    let urlResponse: URLResponse
}

class PixabayLoadImageParser: ParserProtocol {
    
    typealias Model = PixabayLoadedImage
    
    func parse(data: Data, response: URLResponse) -> PixabayLoadedImage {
        return PixabayLoadedImage(data: data, urlResponse: response)
    }
}
