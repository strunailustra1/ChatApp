//
//  RequestSender.swift
//  ChatApp
//
//  Created by Наталья Мирная on 18.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

enum RequestSenderError: Error {
    case undefinedUrlRequest
    case undefinedUrlSession
    case networkError
}

class RequestSender: RequestSenderProtocol {
    
    func send<Parser>(requestConfig config: RequestConfig<Parser>,
                      completionHandler: @escaping (Result<Parser.Model, Error>) -> Void) {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(Result.failure(RequestSenderError.undefinedUrlRequest))
            return
        }
        
        guard let urlSession = config.session.urlSession else {
            completionHandler(Result.failure(RequestSenderError.undefinedUrlSession))
            return
        }
        
        let task = urlSession.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(Result.failure(error))
                return
            }
            
            guard let data = data, let response = response else {
                completionHandler(Result.failure(RequestSenderError.networkError))
                return
            }
            
            let parsedModel: Parser.Model = config.parser.parse(data: data, response: response)

            completionHandler(Result.success(parsedModel))
        }

        task.resume()
    }
}
