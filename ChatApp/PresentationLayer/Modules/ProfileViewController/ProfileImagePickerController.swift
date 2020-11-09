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
    func configureAndPresent(
        delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate & UIViewController,
        sourceType: UIImagePickerController.SourceType) {
        if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let message = sourceType == .camera
                ? "Camera is not available on this device"
                : "Gallery is not available now"
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            delegate.present(alertController, animated: true, completion: nil)
        } else {
            self.delegate = delegate
            self.sourceType = sourceType
            self.allowsEditing = true
            if self.sourceType == .camera {
                self.cameraCaptureMode = .photo
                self.showsCameraControls = true
            }
            if self.sourceType == .photoLibrary {
                self.modalPresentationStyle = .fullScreen
            }
            delegate.present(self, animated: true, completion: nil)
        }
    }
}
