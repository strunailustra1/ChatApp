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
    
    @IBOutlet weak var gcdButton: UIButton!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var fullNameText: UITextField!
    @IBOutlet weak var operationButton: UIButton!
    
    private let notificationCenter = NotificationCenter.default
    
    private var oldProfile = ProfileStorage.shared {
        didSet {
            self.updateSaveButtonAvailability()
        }
    }
    
    private var newProfile = ProfileStorage.shared {
        didSet {
            self.updateSaveButtonAvailability()
        }
    }
    
    private var photoHasBeenChanged = false {
        didSet {
            self.updateSaveButtonAvailability()
        }
    }
    
    lazy private var activityIndicator: UIActivityIndicatorView = { [unowned self] in
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.center = view.center
        return activityIndicator
    }()
    
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
        setupText()
        setupNavigationContoller()
        fullNameText.delegate = self
        descriptionTextView.delegate = self
        
        view.addSubview(activityIndicator)
        
        view.backgroundColor = ThemesManager.shared.getTheme().profileVCBackgroundColor
        
        updateSaveButtonAvailability()
        
        Logger.shared.vcLog(description: "has loaded its view hierarchy into memory")
        Logger.shared.vcLog(frame: "\(gcdButton.frame)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        Logger.shared.vcLog(stateFrom: "Disappeared", stateTo: "Appearing")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         В viewDidLoad() приведен расчет значений для девайса, выбранного в storyboard.
         В viewDidAppear() уже известны и отрисованы размеры девайса в симуляторе.
         */
        Logger.shared.vcLog(frame: "\(gcdButton.frame)")
        
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
        
        gcdButton.layer.cornerRadius = 14
        operationButton.layer.cornerRadius = 14
        
        if view.frame.width < 375 { // Iphone SE
            logoLabel.font = UIFont(name: "Roboto-Regular", size: 80)
        }
        
        Logger.shared.vcLog(description: "view has just laid out its subviews")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        Logger.shared.vcLog(stateFrom: "Appeared", stateTo: "Disappearing")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.shared.vcLog(stateFrom: "Disappearing", stateTo: "Disappeared")
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        presentEditAlert()
    }

    @IBAction func gcdAction() {
        saveProfile(dataManager: GCDDataManager.shared)
    }
    
    @IBAction func operationAction() {
        saveProfile(dataManager: OperationDataManager.shared)
    }
    
    private func saveProfile(dataManager: ProfileDataManagerProtocol) {
        dataManager.save(
            profile: newProfile,
            changedFields: ProfileChangedFields(
                fullnameChanged: oldProfile.fullname != newProfile.fullname,
                descriptionChanged: oldProfile.description != newProfile.description,
                profileImageChanged: photoHasBeenChanged
            ),
            succesfullCompletion: { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.setupText()
                self?.editButton.isEnabled = false
                self?.successSaveAlert()
                if let newProfile = self?.newProfile {
                    self?.oldProfile = newProfile
                    self?.photoHasBeenChanged = false
                    ProfileStorage.shared = newProfile
                }
            },
            errorCompletion: { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.fullNameText.resignFirstResponder()
                self?.descriptionTextView.resignFirstResponder()
                self?.errorSaveAlert(dataManager: dataManager)
                self?.updateSaveButtonAvailability()
            }
        )
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
    
    private func successSaveAlert() {
        let alert = UIAlertController(title: "Data saved", message: nil, preferredStyle: .alert)
        let OkAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(OkAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func errorSaveAlert(dataManager: ProfileDataManagerProtocol) {
        let alert = UIAlertController(title: "Error", message: "Failed to save data", preferredStyle: .alert)
        let OkAction = UIAlertAction(title: "OK", style: .default)
        let repeatAction = UIAlertAction(title: "Repeat", style: .default, handler: { [unowned self] _ in
            self.saveProfile(dataManager: dataManager)
        })
        alert.addAction(OkAction)
        alert.addAction(repeatAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func setupSaveButton() {
        gcdButton.layer.backgroundColor = ThemesManager.shared.getTheme().profileVCButtonBackgroundColor
        gcdButton.clipsToBounds = true
        gcdButton.setTitle("GCD", for: .normal)
        
        operationButton.layer.backgroundColor = ThemesManager.shared.getTheme().profileVCButtonBackgroundColor
        operationButton.clipsToBounds = true
        operationButton.setTitle("Operation", for: .normal)
    }
    
    private func setupEditButton() {
        editButton.layer.backgroundColor = .none
        editButton.setTitleColor(UIColor.gray, for: .normal)
        editButton.setTitle("Edit", for: .normal)
        editButton.isEnabled = false
    }
    
    private func setupLabels() {
        logoLabel.text = newProfile.initials
        logoLabel.font = UIFont(name: "Roboto-Regular", size: 120)
        logoLabel.textColor = UIColor(red: 0.212, green: 0.216, blue: 0.22, alpha: 1)
    }
    
    private func setupText() {
        fullNameText.text = newProfile.fullname
        fullNameText.placeholder = "Username"
        fullNameText.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        fullNameText.textAlignment = .center
        fullNameText.backgroundColor = ThemesManager.shared.getTheme().profileVCBackgroundColor
        fullNameText.textColor = ThemesManager.shared.getTheme().labelTextColor
        fullNameText.layer.borderWidth = 0
        fullNameText.resignFirstResponder()
        
        let descriptionParagraphStyle = NSMutableParagraphStyle()
        descriptionParagraphStyle.lineHeightMultiple = 1.15
        descriptionTextView.attributedText = NSMutableAttributedString(string: newProfile.description, attributes: [NSAttributedString.Key.kern: -0.33, NSAttributedString.Key.paragraphStyle: descriptionParagraphStyle, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        descriptionTextView.backgroundColor = ThemesManager.shared.getTheme().profileVCBackgroundColor
        descriptionTextView.textColor = ThemesManager.shared.getTheme().labelTextColor
        descriptionTextView.layer.borderWidth = 0
        descriptionTextView.resignFirstResponder()
        
        fullNameText.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
    }
    
    private func setupPhotoView() {
        photoView.layer.cornerRadius = photoView.frame.width / 2
        photoView.clipsToBounds = true
        
        if let image = newProfile.profileImage {
            photoView.image = image
            photoView.contentMode = photoView.frame.width > photoView.frame.height ? .scaleAspectFit : .scaleAspectFill
            logoLabel.isHidden = true
        }
    }
    
    private func setupNavigationContoller() {
        navigationItem.title = "My Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeProfile))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editProfile))
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .semibold)], for: .normal)
    }
    
    private func updateSaveButtonAvailability() {
        let isEnabled = photoHasBeenChanged || oldProfile.fullname != newProfile.fullname || oldProfile.description != newProfile.description
        
        gcdButton.isEnabled = isEnabled
        operationButton.isEnabled = isEnabled
    }
    
    @objc func closeProfile() {
        dismiss(animated: true, completion: closeHandler)
    }
    
    @objc func editProfile() {
        fullNameText.isUserInteractionEnabled = true
        fullNameText.layer.borderWidth = 1
        fullNameText.layer.borderColor = ThemesManager.shared.getTheme().labelBorderColor
        
        descriptionTextView.isUserInteractionEnabled = true
        descriptionTextView.layer.borderColor = ThemesManager.shared.getTheme().labelBorderColor
        descriptionTextView.layer.borderWidth = 1
        
        editButton.isEnabled = true
        
        fullNameText.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y = keyboardSize.height > 226 ? -250 : -keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else { return }
        let newProfile = Profile(fullname: self.newProfile.fullname,
                                 description: self.newProfile.description,
                                 profileImage: image)
        self.newProfile = newProfile
        
        ProfileComparator.isEqualImage(
            oldProfile: oldProfile,
            newProfile: newProfile,
            completion: { [weak self] photoHasBeenChanged in
                self?.photoHasBeenChanged = photoHasBeenChanged
            }
        )
        
        setupPhotoView()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UITextFieldDelegate, UITextViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateNewProfile(fullname: textField.text, description: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let textFieldString = textField.fullTextWith(range: range, replacementString: string) {
            updateNewProfile(fullname: textFieldString, description: nil)
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateNewProfile(fullname: nil, description: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textFieldString = textView.fullTextWith(range: range, replacementString: text) {
            updateNewProfile(fullname: nil, description: textFieldString)
        }
        return true
    }
    
    private func updateNewProfile(fullname: String?, description: String?) {
        let profile = Profile(fullname: fullname ?? self.newProfile.fullname,
                              description: description ?? self.newProfile.description,
                              profileImage: self.newProfile.profileImage)
        self.newProfile = profile
    }
}

class UIButtonDisableColored: UIButton {
    override var isEnabled: Bool {
        didSet {
            setTitleColor(isEnabled ? UIColor.systemBlue : UIColor.gray, for: .normal)
        }
    }
}
