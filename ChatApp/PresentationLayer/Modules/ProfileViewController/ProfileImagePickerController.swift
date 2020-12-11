//
//  ProfileImagePickerController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 22.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

class ProfileImagePickerController: UIImagePickerController {

    weak var changeProfilePhotoDelegate: ChangeProfilePhotoDelegate?
    
    func configure(
        sourceType: UIImagePickerController.SourceType,
        changeProfilePhotoDelegate: ChangeProfilePhotoDelegate
    ) -> UIViewController {
        if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let message = sourceType == .camera
                ? "Camera is not available on this device"
                : "Gallery is not available now"
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            return alertController
        } else {
            self.delegate = self
            self.sourceType = sourceType
            self.allowsEditing = true
            if self.sourceType == .camera {
                self.cameraCaptureMode = .photo
                self.showsCameraControls = true
            }
            if self.sourceType == .photoLibrary {
                self.modalPresentationStyle = .fullScreen
            }
            self.changeProfilePhotoDelegate = changeProfilePhotoDelegate
            return self
        }
    }
}

extension ProfileImagePickerController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        changeProfilePhotoDelegate?.changeProfilePhoto(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
