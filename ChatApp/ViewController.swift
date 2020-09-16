//
//  ViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.vcLog(description: "has loaded its view hierarchy into memory")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Logger.vcLog(stateFrom: "Disappeared", stateTo: "Appearing")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Logger.vcLog(stateFrom: "Appearing", stateTo: "Appeared")
    }
  
    override func viewWillLayoutSubviews() {
        //super.viewWillLayoutSubviews() не вызывается, так как по умолчанию данный метод ничего не делает
        Logger.vcLog(description: "view is about to layout its subviews")
    }
    
    override func viewDidLayoutSubviews() {
        //super.viewDidLayoutSubviews() не вызывается, так как по умолчанию данный метод ничего не делает
        Logger.vcLog(description: "view has just laid out its subviews")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Logger.vcLog(stateFrom: "Appeared", stateTo: "Disappearing")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.vcLog(stateFrom: "Disappearing", stateTo: "Disappeared")
    }
}

