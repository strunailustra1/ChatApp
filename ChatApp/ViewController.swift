//
//  ViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var careerAndCityLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
       // print(saveButton.frame) на момент инициализации контроллера еще неизвестны размеры элементов, расположенных на экране, все значения равны nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(saveButton.frame)
        settingForSaveAction()
        settingForEditAction()
        fullNameLabel.font = UIFont(name: "SFProDisplay-Bold", size: 24)
        careerAndCityLabel.font = UIFont(name: "SFProText-Regular", size: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.15
        careerAndCityLabel.attributedText = NSMutableAttributedString(string: "UX/UI designer, web-designer\nMoscow, Russia", attributes: [NSAttributedString.Key.kern: -0.33, NSAttributedString.Key.paragraphStyle: paragraphStyle])
       // print(fullNameLabel.font)
        Logger.vcLog(description: "has loaded its view hierarchy into memory")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Logger.vcLog(stateFrom: "Disappeared", stateTo: "Appearing")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(saveButton.frame)
        //во viewDidLoad() приведен расчет значений для девайса, выбранного в storyboard, во viewDidAppear() уже известны и отрисованы размеры девайса в симуляторе
        Logger.vcLog(stateFrom: "Appearing", stateTo: "Appeared")
    }
  
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        saveButton.layer.cornerRadius = 14
        Logger.vcLog(description: "view is about to layout its subviews")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoView.layer.cornerRadius = photoView.frame.width / 2
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
    
    private func settingForSaveAction() {
        saveButton.layer.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1).cgColor
        saveButton.setTitleColor(UIColor(red: 0, green: 0.478, blue: 1, alpha: 1), for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "SFProText-Semibold", size: 19)
        saveButton.clipsToBounds = true
        saveButton.setTitle("Save", for: .normal)
    }
    
    private func settingForEditAction() {
        editButton.layer.backgroundColor = .none
        editButton.tintColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
        editButton.titleLabel?.font = UIFont(name: "SFProText-Semibold", size: 16)
        editButton.setTitle("Edit", for: .normal)
    }
}

