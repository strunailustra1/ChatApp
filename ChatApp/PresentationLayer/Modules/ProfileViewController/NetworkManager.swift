//
//  NetworkManager.swift
//  ChatApp
//
//  Created by Наталья Мирная on 16.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

struct ApiResult: Decodable {
    let total: Int?
    let totalHits: Int?
    let hits: [ApiImage]?
}

struct ApiImage: Decodable {
    let id: Int?
    let pageURL: String?
    let type: String?
    let tags: String?
    let previewURL: String?
    let previewWidth: Int?
    let previewHeight: Int?
    let webformatURL: String?
    let webformatWidth: Int?
    let webformatHeight: Int?
    let largeImageURLg: String?
    let imageWidth: Int?
    let imageHeight: Int?
    let imageSize: Int?
    let views: Int?
    let downloads: Int?
    let favorites: Int?
    let likes: Int?
    let comments: Int?
    let user_id: Int?
    let user: String?
    let userImageURL: String?
}

class NetworkManager {
    
    static let shared = NetworkManager()
    let session = URLSession.shared
    
    let token = "19137210-0a0bbcfeab89161406b938546"
    let imagesURL = "https://pixabay.com/api/"
    
    func fetchImages(
        query: String,
        succesfullCompletion: @escaping(ApiResult) -> Void,
        errorCompletion: ((Error) -> Void)? = nil
    ) {
        guard let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let apiUrl = "\(imagesURL)?key=\(token)&q=\(queryEncoded)&image_type=photo&pretty=true&per_page=100"
        guard let url = URL(string: apiUrl) else { return }
        session.dataTask(with: url) { (data, _, error) in
            //sleep(2)
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let apiResult = try decoder.decode(ApiResult.self, from: data)
                succesfullCompletion(apiResult)
            } catch {
                fatalError(error.localizedDescription)
            }
        }.resume()
    }
    
    func getImage(from url: URL, completion: @escaping(Data, URLResponse) -> Void) {
        session.dataTask(with: url) { (data, response, error) in
            //sleep(1)
            
            if let error = error {
                print(error)
                return
            }
            guard let data = data, let response = response else { return }
            guard let responseURL = response.url else { return }
            if url != responseURL { return }
            completion(data, response)
        }.resume()
    }
}
