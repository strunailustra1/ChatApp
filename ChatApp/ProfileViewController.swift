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
    
    var closeHandler: (() -> Void)?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSaveButton()
        setupEditButton()
        setupLogoLabel()
        setupTextInputs()
        setupNavigationContoller()
        fullNameText.delegate = self
        descriptionTextView.delegate = self
        
        view.addSubview(activityIndicator)
        
        view.backgroundColor = ThemesManager.shared.getTheme().profileVCBackgroundColor
        
        updateSaveButtonAvailability()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillShow(sender:)),
                                       name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillHide(sender:)),
                                       name: UIResponder.keyboardWillHideNotification, object: nil)
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        presentEditPhotoAlert()
    }
    
    @IBAction func gcdAction() {
        saveProfile(dataManager: GCDDataManager.shared)
    }
    
    @IBAction func operationAction() {
        saveProfile(dataManager: OperationDataManager.shared)
    }

    @objc func closeProfile() {
        dismiss(animated: true, completion: closeHandler)
    }
    
    @objc func editProfile() {
        fullNameText.isUserInteractionEnabled = true
        fullNameText.layer.borderColor = ThemesManager.shared.getTheme().labelBorderColor
        fullNameText.layer.borderWidth = 1
        
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

extension ProfileViewController {
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
        editButton.setTitle("Edit", for: .normal)
        editButton.isEnabled = false
    }
    
    private func setupLogoLabel() {
        logoLabel.text = newProfile.initials
        logoLabel.font = UIFont(name: "Roboto-Regular", size: 120)
        logoLabel.textColor = UIColor(red: 0.212, green: 0.216, blue: 0.22, alpha: 1)
    }
    
    private func setupTextInputs() {
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
        descriptionTextView.attributedText = NSMutableAttributedString(
            string: newProfile.description,
            attributes: [
                NSAttributedString.Key.kern: -0.33,
                NSAttributedString.Key.paragraphStyle: descriptionParagraphStyle
            ]
        )
        descriptionTextView.attributedText = NSMutableAttributedString(
            string: newProfile.description,
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(closeProfile))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editProfile))
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)],
            for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)],
            for: .normal)
    }
}

extension ProfileViewController {
    private func saveProfile(dataManager: ProfileDataManagerProtocol) {
        gcdButton.isEnabled = false
        operationButton.isEnabled = false
        activityIndicator.startAnimating()
        
        dataManager.save(
            profile: newProfile,
            changedFields: ProfileChangedFields(
                fullnameChanged: oldProfile.fullname != newProfile.fullname,
                descriptionChanged: oldProfile.description != newProfile.description,
                profileImageChanged: photoHasBeenChanged
            ),
            succesfullCompletion: { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.setupTextInputs()
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
    
    private func updateSaveButtonAvailability() {
        let isEnabled = photoHasBeenChanged
            || oldProfile.fullname != newProfile.fullname
            || oldProfile.description != newProfile.description
        
        gcdButton.isEnabled = isEnabled
        operationButton.isEnabled = isEnabled
    }
}

extension ProfileViewController {
    private func presentEditPhotoAlert() {
        let alert = ProfileEditImageAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.configure(
            galleryHandler: { [unowned self] _ in
                self.presentImagePickerController(from: .photoLibrary)
            }, photoHandler: { [unowned self] _ in
                self.presentImagePickerController(from: .camera)
            }
        )
        present(alert, animated: true, completion: nil)
    }
    
    private func presentImagePickerController(from sourceType: UIImagePickerController.SourceType) {
        let pickerController = ProfileImagePickerController()
        pickerController.configureAndPresent(delegate: self, sourceType: sourceType)
    }
}

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let profile = Profile(fullname: self.newProfile.fullname,
                              description: self.newProfile.description,
                              profileImage: image)
        self.newProfile = profile
        
        ProfileComparator.isEqualImages(
            oldProfile: oldProfile,
            newProfile: newProfile,
            completion: { [weak self] isEqualImages in
                self?.photoHasBeenChanged = !isEqualImages
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
        if touches.first != nil {
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
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
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
