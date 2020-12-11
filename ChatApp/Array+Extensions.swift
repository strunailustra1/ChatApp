//
//  Array+Extensions.swift
//  ChatApp
//
//  Created by Наталья Мирная on 27.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

extension Array where Element: Collection,
Element.Iterator.Element: Equatable, Element.Index == Int {
    
    func indices(of x: Element.Iterator.Element) -> (Int, Int)? {
        for (i, row) in self.enumerated() {
            if let j = row.firstIndex(of: x) {
                return (i, j)
            }
        }
        return nil
    }
}
