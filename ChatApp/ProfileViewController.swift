//
//  ViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    static func storyboardInstance() -> ProfileViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? ProfileViewController
    }

 //   let profile = ProfileViewController.storyboardInstance()
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logoLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        /*
         На момент инициализации контроллера еще не проинициализированы аутлеты,
         расположенные на экране, все значения равны nil.
         Аутлеты будут проинициализированы в loadView().
         */
        // Logger.vcLog(frame: "\(saveButton.frame)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSaveButton()
        setupEditButton()
        setupLabels()
        
        Logger.shared.vcLog(description: "has loaded its view hierarchy into memory")
        Logger.shared.vcLog(frame: "\(saveButton.frame)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Logger.shared.vcLog(stateFrom: "Disappeared", stateTo: "Appearing")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         В viewDidLoad() приведен расчет значений для девайса, выбранного в storyboard.
         В viewDidAppear() уже известны и отрисованы размеры девайса в симуляторе.
         */
        Logger.shared.vcLog(frame: "\(saveButton.frame)")
        
        Logger.shared.vcLog(stateFrom: "Appearing", stateTo: "Appeared")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        Logger.shared.vcLog(description: "view is about to layout its subviews")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        photoView.layer.cornerRadius = photoView.frame.width / 2
        photoView.clipsToBounds = true
        
        logoLabel.layer.cornerRadius = logoLabel.frame.width / 2
        logoLabel.clipsToBounds = true
        
        saveButton.layer.cornerRadius = 14
        
        if view.frame.width < 375 { // Iphone SE
            logoLabel.font = UIFont(name: "Roboto-Regular", size: 80)
        }
        
        Logger.shared.vcLog(description: "view has just laid out its subviews")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Logger.shared.vcLog(stateFrom: "Appeared", stateTo: "Disappearing")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.shared.vcLog(stateFrom: "Disappearing", stateTo: "Disappeared")
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        presentEditAlert()
    }
    
    private func presentPickerController(from sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        
        if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let message = sourceType == .camera ? "Camera is not available on this device" : "Gallery is not available now"
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            pickerController.delegate = self
            pickerController.sourceType = sourceType
            pickerController.allowsEditing = true
            if pickerController.sourceType == .camera {
                pickerController.cameraCaptureMode = .photo
                pickerController.showsCameraControls = true
            }
            if pickerController.sourceType == .photoLibrary {
                pickerController.modalPresentationStyle = .fullScreen
            }
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    private func presentEditAlert() {
        let alert = UIAlertController(title: nil, message: "Edit photo", preferredStyle: .actionSheet)
        
        let galleryAction = UIAlertAction(title: "Choose in gallery", style: .default, handler: { [unowned self] _ in
            self.presentPickerController(from: .photoLibrary)
        })
        let photoAction = UIAlertAction(title: "Take photo", style: .default, handler: { [unowned self] _ in
            self.presentPickerController(from: .camera)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(galleryAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)
        
        alert.pruneNegativeWidthConstraints()
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setupSaveButton() {
        saveButton.layer.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1).cgColor
        saveButton.setTitleColor(UIColor(red: 0, green: 0.478, blue: 1, alpha: 1), for: .normal)
        saveButton.clipsToBounds = true
        saveButton.setTitle("Save", for: .normal)
    }
    
    private func setupEditButton() {
        editButton.layer.backgroundColor = .none
        editButton.setTitleColor(UIColor(red: 0, green: 0.478, blue: 1, alpha: 1), for: .normal)
        editButton.setTitle("Edit", for: .normal)
    }
    
    private func setupLabels() {
        fullNameLabel.text = "Marina Dudarenko"
        logoLabel.text = "MD"
        
        let descriptionParagraphStyle = NSMutableParagraphStyle()
        descriptionParagraphStyle.lineHeightMultiple = 1.15
        descriptionLabel.attributedText = NSMutableAttributedString(string: "UX/UI designer, web-designer\nMoscow, Russia", attributes: [NSAttributedString.Key.kern: -0.33, NSAttributedString.Key.paragraphStyle: descriptionParagraphStyle])

        logoLabel.font = UIFont(name: "Roboto-Regular", size: 120)
        logoLabel.textColor = UIColor(red: 0.212, green: 0.216, blue: 0.22, alpha: 1)
    }
}

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else { return }
        photoView.image = image
        photoView.contentMode = photoView.frame.width > photoView.frame.height ? .scaleAspectFit : .scaleAspectFill
        logoLabel.isHidden = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
