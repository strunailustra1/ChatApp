//
//  ResponseCacheProtocol.swift
//  ChatApp
//
//  Created by Наталья Мирная on 20.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

protocol ResponseCacheProtocol {
    func saveImageToCash(data: Data, response: URLResponse)
    func getCachedImage(url: URL) -> UIImage?
}
