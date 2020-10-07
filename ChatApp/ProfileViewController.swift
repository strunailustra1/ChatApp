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
    
    var closeHandler: (() -> ())?
    
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
        setupNavigationContoller()
        
        view.backgroundColor = ThemesManager.shared.getTheme().profileVCBackgroundColor
        
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
        
        setupPhotoView()
        
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let galleryAction = UIAlertAction(title: "Photo Gallery", style: .default, handler: { [unowned self] _ in
            self.presentPickerController(from: .photoLibrary)
        })
        let photoAction = UIAlertAction(title: "Camera", style: .default, handler: { [unowned self] _ in
            self.presentPickerController(from: .camera)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(galleryAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)

        alert.setValue(NSAttributedString(string: "Edit photo", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .semibold)]), forKey: "attributedTitle")
        alert.setValue(NSAttributedString(string: "Please, choose one of the ways", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)]), forKey: "attributedMessage")
        
        alert.pruneNegativeWidthConstraints()
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setupSaveButton() {
        saveButton.layer.backgroundColor = ThemesManager.shared.getTheme().profileVCButtonBackgroundColor
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
        fullNameLabel.text = ProfileStorage.shared.fullname
        logoLabel.text = ProfileStorage.shared.initials
        
        let descriptionParagraphStyle = NSMutableParagraphStyle()
        descriptionParagraphStyle.lineHeightMultiple = 1.15
        descriptionLabel.attributedText = NSMutableAttributedString(string: ProfileStorage.shared.description, attributes: [NSAttributedString.Key.kern: -0.33, NSAttributedString.Key.paragraphStyle: descriptionParagraphStyle])
        
        logoLabel.font = UIFont(name: "Roboto-Regular", size: 120)
        logoLabel.textColor = UIColor(red: 0.212, green: 0.216, blue: 0.22, alpha: 1)
    }
    
    private func setupPhotoView() {
        photoView.layer.cornerRadius = photoView.frame.width / 2
        photoView.clipsToBounds = true
        
        if let image = ProfileStorage.shared.profileImage {
            photoView.image = image
            photoView.contentMode = photoView.frame.width > photoView.frame.height ? .scaleAspectFit : .scaleAspectFill
            logoLabel.isHidden = true
        }
    }
    
    private func setupNavigationContoller() {
        navigationItem.title = "My Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeProfile))
    }
    
    @objc func closeProfile() {
        dismiss(animated: true, completion: closeHandler)
    }
}

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else { return }
        ProfileStorage.shared.profileImage = image
        setupPhotoView()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

/*
 https://stackoverflow.com/questions/55653187/swift-default-alertviewcontroller-breaking-constraints/58666480#58666480
 */
extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
