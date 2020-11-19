//
//  PixabaySearchImageParser.swift
//  ChatApp
//
//  Created by Наталья Мирная on 18.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

struct PixabaySearchImageResult: Decodable {
    let hits: [PixabayImage]?
}

struct PixabayImage: Decodable {
    let id: Int?
    let type: String?
    let previewURL: String?
    let webformatURL: String?
}

class PixabaySearchImageParser: ParserProtocol {
    
    typealias Model = [PixabayImage]?
    
    func parse(data: Data, response: URLResponse) -> [PixabayImage]? {
        do {
            let decoder = JSONDecoder()
            let apiResult = try decoder.decode(PixabaySearchImageResult.self, from: data)
            return apiResult.hits
        } catch {
            return nil
        }
    }
}
