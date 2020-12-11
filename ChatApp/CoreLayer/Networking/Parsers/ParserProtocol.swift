//
//  ParserProtocol.swift
//  ChatApp
//
//  Created by Наталья Мирная on 18.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

protocol ParserProtocol {
    associatedtype Model
    
    func parse(data: Data, response: URLResponse) -> Model
}
