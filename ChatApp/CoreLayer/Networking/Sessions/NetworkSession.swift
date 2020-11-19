//
//  NetworkSession.swift
//  ChatApp
//
//  Created by Наталья Мирная on 19.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

class NetworkSession: SessionProtocol {
    var urlSession: URLSession?
    
    init(urlSession: URLSession?) {
        self.urlSession = urlSession
    }
}
