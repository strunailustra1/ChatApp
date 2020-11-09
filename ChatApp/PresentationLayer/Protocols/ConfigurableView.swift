//
//  ConfigurableView.swift
//  ChatApp
//
//  Created by Наталья Мирная on 25.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

protocol ConfigurableView {
    associatedtype ConfigurationModel
    
    func configure(with model: ConfigurationModel, theme: Theme?)
}
