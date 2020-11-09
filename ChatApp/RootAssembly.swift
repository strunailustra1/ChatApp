//
//  RootAssembly.swift
//  ChatApp
//
//  Created by Наталья Мирная on 09.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

class RootAssembly {
    lazy var presentationAssembly: PresentationAssemblyProtocol = PresentationAssembly(serviceAssembly:
        self.serviceAssembly)
    private lazy var serviceAssembly: ServicesAssemblyProtocol = ServicesAssembly(coreAssembly: self.coreAssembly)
    private lazy var coreAssembly: CoreAssemblyProtocol = CoreAssembly()
    
    // нужен для установки темы при запуске приложения в AppDelegate
    lazy var themesManager: ThemesManagerProtocol = {
        return serviceAssembly.themesManager
    }()
}
