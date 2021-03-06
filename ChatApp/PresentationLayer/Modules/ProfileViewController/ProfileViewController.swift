//
//  ViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    static func storyboardInstance(settings: ProfileViewControllerSettings) -> ProfileViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        let profileVC = storyboard.instantiateInitialViewController() as? ProfileViewController
        
        profileVC?.themesManager = settings.themesManager
        profileVC?.imageComparator = settings.imageComparator
        profileVC?.profileRepository = settings.profileRepository
        profileVC?.profileTextFieldDelegate = settings.profileTextFieldDelegate
        profileVC?.profileTextViewDelegate = settings.profileTextViewDelegate
        profileVC?.router = settings.router
        
        return profileVC
    }

    var themesManager: ThemesManagerProtocol?
    var imageComparator: ImageComparatorProtocol?
    var profileRepository: ProfileRepositoryProtocol?
    var profileTextFieldDelegate: TextFieldDelegateWithCompletion?
    var profileTextViewDelegate: TextViewDelegateWithCompletion?
    var router: RouterProtocol?
    var closeHandler: (() -> Void)?
    
    @IBOutlet weak var gcdButton: UIButton!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var fullNameText: UITextField!
    @IBOutlet weak var operationButton: UIButton!
    
    private let notificationCenter = NotificationCenter.default
    
    private var oldProfile: Profile? {
        didSet {
            self.updateSaveButtonAvailability()
        }
    }
    
    private var newProfile: Profile? {
        didSet {
            self.updateSaveButtonAvailability()
        }
    }
    
    private var photoHasBeenChanged = false {
        didSet {
            self.updateSaveButtonAvailability()
        }
    }
    
    private var onEditingMode = false {
        didSet {
            onEditingMode ? startEditingMode() : endEditingMode()
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
        
        oldProfile = profileRepository?.profile
        newProfile = profileRepository?.profile
        
        setupSaveButton()
        setupEditButton()
        setupLogoLabel()
        setupTextInputs()
        setupNavigationContoller()
        
        profileTextFieldDelegate?.endEditingCompletion = { [weak self] fullname in
            self?.updateProfileTextFields(fullname: fullname, description: nil)
        }
        fullNameText.delegate = profileTextFieldDelegate
        
        profileTextViewDelegate?.endEditingCompletion = { [weak self] description in
            self?.updateProfileTextFields(fullname: nil, description: description)
        }
        descriptionTextView.delegate = profileTextViewDelegate
        
        view.addSubview(activityIndicator)
        view.backgroundColor = themesManager?.getTheme().profileVCBackgroundColor
        
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
        saveProfile(by: .gcd)
    }
    
    @IBAction func operationAction() {
        saveProfile(by: .operation)
    }

    @objc func closeProfile() {
        dismiss(animated: true, completion: closeHandler)
    }
    
    @objc func editProfile() {
        onEditingMode.toggle()
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
        gcdButton.layer.backgroundColor = themesManager?.getTheme().profileVCButtonBackgroundColor
        gcdButton.clipsToBounds = true
        gcdButton.setTitle("GCD", for: .normal)
        gcdButton.layer.cornerRadius = 14
        
        operationButton.layer.backgroundColor = themesManager?.getTheme().profileVCButtonBackgroundColor
        operationButton.clipsToBounds = true
        operationButton.setTitle("Operation", for: .normal)
        operationButton.layer.cornerRadius = 14
    }
    
    private func setupEditButton() {
        editButton.layer.backgroundColor = .none
        editButton.setTitle("Edit", for: .normal)
        editButton.isEnabled = false
    }
    
    private func setupLogoLabel() {
        logoLabel.text = newProfile?.initials
        logoLabel.font = UIFont(name: "Roboto-Regular", size: 120)
        logoLabel.textColor = UIColor(red: 0.212, green: 0.216, blue: 0.22, alpha: 1)
    }
    
    private func setupTextInputs() {
        fullNameText.text = newProfile?.fullname
        fullNameText.placeholder = "Username"
        fullNameText.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        fullNameText.textAlignment = .center
        fullNameText.backgroundColor = themesManager?.getTheme().profileVCBackgroundColor
        fullNameText.textColor = themesManager?.getTheme().labelTextColor
        fullNameText.layer.borderWidth = 0
        fullNameText.accessibilityIdentifier = "fullNameTextIdentifier"
        fullNameText.resignFirstResponder()
        
        let descriptionParagraphStyle = NSMutableParagraphStyle()
        descriptionParagraphStyle.lineHeightMultiple = 1.15
        descriptionTextView.attributedText = NSMutableAttributedString(
            string: newProfile?.description ?? "",
            attributes: [
                NSAttributedString.Key.kern: -0.33,
                NSAttributedString.Key.paragraphStyle: descriptionParagraphStyle
            ]
        )
        descriptionTextView.attributedText = NSMutableAttributedString(
            string: newProfile?.description ?? "",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )
        descriptionTextView.backgroundColor = themesManager?.getTheme().profileVCBackgroundColor
        descriptionTextView.textColor = themesManager?.getTheme().labelTextColor
        descriptionTextView.layer.borderWidth = 0
        descriptionTextView.accessibilityIdentifier = "descriptionTextIdentifier"
        descriptionTextView.resignFirstResponder()

        fullNameText.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
    }
    
    private func setupPhotoView() {
        photoView.layer.cornerRadius = photoView.frame.width / 2
        photoView.clipsToBounds = true
        
        if let image = newProfile?.profileImage {
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
    
    private func startEditingMode() {
        fullNameText.isUserInteractionEnabled = true
        fullNameText.layer.borderColor = themesManager?.getTheme().labelBorderColor
        fullNameText.layer.borderWidth = 1
        
        descriptionTextView.isUserInteractionEnabled = true
        descriptionTextView.layer.borderColor = themesManager?.getTheme().labelBorderColor
        descriptionTextView.layer.borderWidth = 1
        
        editButton.isEnabled = true
        ShakeAnimation.startShaking(for: editButton)
        
        fullNameText.becomeFirstResponder()
    }
    
    private func endEditingMode() {
        setupTextInputs()
        ShakeAnimation.stopShaking(for: editButton)
        editButton.isEnabled = false
    }
}

extension ProfileViewController {
    private func saveProfile(by saveMethod: ProfileStorageType) {
        guard let savedProfile = newProfile else { return }
        
        gcdButton.isEnabled = false
        operationButton.isEnabled = false
        activityIndicator.startAnimating()
        
        profileRepository?.saveToStorage(
            by: saveMethod,
            profile: savedProfile,
            changedFields: ProfileChangedFields(
                fullnameChanged: oldProfile?.fullname != newProfile?.fullname,
                descriptionChanged: oldProfile?.description != newProfile?.description,
                profileImageChanged: photoHasBeenChanged
            ),
            succesfullCompletion: { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.onEditingMode = false
                self?.successSaveAlert()
                if let newProfile = self?.newProfile {
                    self?.oldProfile = newProfile
                    self?.photoHasBeenChanged = false
                }
            },
            errorCompletion: { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.fullNameText.resignFirstResponder()
                self?.descriptionTextView.resignFirstResponder()
                self?.errorSaveAlert(by: saveMethod)
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
    
    private func errorSaveAlert(by saveMethod: ProfileStorageType) {
        let alert = UIAlertController(title: "Error", message: "Failed to save data", preferredStyle: .alert)
        let OkAction = UIAlertAction(title: "OK", style: .default)
        let repeatAction = UIAlertAction(title: "Repeat", style: .default, handler: { [unowned self] _ in
            self.saveProfile(by: saveMethod)
        })
        alert.addAction(OkAction)
        alert.addAction(repeatAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func updateSaveButtonAvailability() {
        let isEnabled = photoHasBeenChanged
            || oldProfile?.fullname != newProfile?.fullname
            || oldProfile?.description != newProfile?.description
        
        gcdButton.isEnabled = isEnabled
        operationButton.isEnabled = isEnabled
    }
}

extension ProfileViewController {
    private func presentEditPhotoAlert() {
        let alert = ProfileEditImageAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.configure(
            galleryHandler: { [unowned self] _ in
                self.presentImagePickerControllerOrAlert(from: .photoLibrary)
            },
            photoHandler: { [unowned self] _ in
                self.presentImagePickerControllerOrAlert(from: .camera)
            },
            downloadHandler: { [unowned self] _ in
                self.router?.presentImageVC(modalFrom: self, changeProfilePhotoDelegate: self)
            }
        )
        present(alert, animated: true, completion: nil)
    }
    
    private func presentImagePickerControllerOrAlert(from sourceType: UIImagePickerController.SourceType) {
        let presentedVC = ProfileImagePickerController().configure(sourceType: sourceType,
                                                                   changeProfilePhotoDelegate: self)
        present(presentedVC, animated: true, completion: nil)
    }
}

extension ProfileViewController: ChangeProfilePhotoDelegate {
    func changeProfilePhoto(_ image: UIImage) {
        let profile = Profile(fullname: newProfile?.fullname ?? "",
                              description: newProfile?.description ?? "",
                              profileImage: image)
        newProfile = profile
        
        imageComparator?.isEqualImages(
            leftImage: oldProfile?.profileImage,
            rightImage: newProfile?.profileImage,
            completion: { [weak self] isEqualImages in
                self?.photoHasBeenChanged = !isEqualImages
            }
        )
        
        setupPhotoView()
    }
}

extension ProfileViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }
    
    private func updateProfileTextFields(fullname: String?, description: String?) {
        let profile = Profile(fullname: fullname ?? self.newProfile?.fullname ?? "",
                              description: description ?? self.newProfile?.description ?? "",
                              profileImage: self.newProfile?.profileImage)
        self.newProfile = profile
    }
}
