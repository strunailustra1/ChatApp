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
        Logger.vcLog()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Logger.vcLog()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Logger.vcLog()
    }
  
    override func viewWillLayoutSubviews() {
        //super.viewWillLayoutSubviews() не вызывается, так как по умолчанию данный метод ничего не делает
        Logger.vcLog()
    }
    
    override func viewDidLayoutSubviews() {
        //super.viewDidLayoutSubviews() не вызывается, так как по умолчанию данный метод ничего не делает
        Logger.vcLog()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Logger.vcLog()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.vcLog()
    }
}

