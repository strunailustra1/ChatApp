//
//  ProfilePath.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

enum ProfilePath: String {
    case image = "profileImage.png"
    case fullname = "profileFullname.txt"
    case description = "profileDescription.txt"
    
    func getURL() -> URL {
        getDocumentsDirectory().appendingPathComponent(rawValue)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
