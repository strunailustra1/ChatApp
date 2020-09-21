//
//  ViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logoLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        // print(saveButton.frame) на момент инициализации контроллера еще неизвестны размеры элементов, расположенных на экране, все значения равны nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(saveButton.frame)
        setupSaveAction()
        setupEditAction()
        setupLabelFont()
        
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
        photoView.clipsToBounds = true
        logoLabel.layer.cornerRadius = logoLabel.frame.width / 2
        logoLabel.clipsToBounds = true
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
    
    @IBAction func editAction(_ sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let galleryAction = UIAlertAction(title: "Choose in gallery", style: .default, handler: { _ in self.useGallery()
            
        })
        let photoAction = UIAlertAction(title: "Photo", style: .default, handler: { _ in
            self.useCamera()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(galleryAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        alert.pruneNegativeWidthConstraints()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.photoView.image = image
            self.logoLabel.isHidden = true
        } else {
            print("error")
        }
    }
    
//    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
//
//        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
//
//            let imagePickerController = UIImagePickerController()
//            imagePickerController.delegate = self
//            imagePickerController.sourceType = sourceType
//            self.present(imagePickerController, animated: true)
//        }
//    }
    
    func useCamera() {
        let pickerControl = UIImagePickerController()
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: nil, message: "Camera is not available now", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (alert: UIAlertAction!) in
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            pickerControl.sourceType = .camera
            pickerControl.allowsEditing = true
            pickerControl.showsCameraControls = true
            pickerControl.delegate = self
            self.present(pickerControl, animated: true)
        }
    }
    
    func useGallery() {
        let pickerControl = UIImagePickerController()
        
        pickerControl.sourceType = .photoLibrary
        pickerControl.delegate = self
        pickerControl.allowsEditing = true
        self.present(pickerControl, animated: true)
        
    }
    
    private func setupSaveAction() {
        saveButton.layer.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1).cgColor
        saveButton.setTitleColor(UIColor(red: 0, green: 0.478, blue: 1, alpha: 1), for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "SFProText-Semibold", size: 19)
        saveButton.clipsToBounds = true
        saveButton.setTitle("Save", for: .normal)
    }
    
    private func setupEditAction() {
        editButton.layer.backgroundColor = .none
        editButton.tintColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
        editButton.titleLabel?.font = UIFont(name: "SFProText-Semibold", size: 16)
        editButton.setTitle("Edit", for: .normal)
    }
    
    private func setupLabelFont() {
        fullNameLabel.font = UIFont(name: "SFProDisplay-Bold", size: 24)
        descriptionLabel.font = UIFont(name: "SFProText-Regular", size: 16)
        let paragraphStyleOne = NSMutableParagraphStyle()
        paragraphStyleOne.lineHeightMultiple = 1.15
        descriptionLabel.attributedText = NSMutableAttributedString(string: "UX/UI designer, web-designer\nMoscow, Russia", attributes: [NSAttributedString.Key.kern: -0.33, NSAttributedString.Key.paragraphStyle: paragraphStyleOne])
        
        logoLabel.font = UIFont(name: "Roboto-Regular", size: 120)
    }
}

extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
