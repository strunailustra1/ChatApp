//
//  ProfileEditImageAlertController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 22.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

class ProfileEditImageAlertController: UIAlertController {
    func configure(galleryHandler: ((UIAlertAction) -> Void)? = nil,
                   photoHandler: ((UIAlertAction) -> Void)? = nil,
                   downloadHandler: ((UIAlertAction) -> Void)? = nil) {
        
        let galleryAction = UIAlertAction(title: "Photo Gallery", style: .default, handler: galleryHandler)
        let photoAction = UIAlertAction(title: "Camera", style: .default, handler: photoHandler)
        let downloadAction = UIAlertAction(title: "Download", style: .default, handler: downloadHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        addAction(galleryAction)
        addAction(photoAction)
        addAction(downloadAction)
        addAction(cancelAction)
        
        setValue(NSAttributedString(string: "Edit photo",
                                    attributes: [NSAttributedString.Key.font:
                                        UIFont.systemFont(ofSize: 20, weight: .semibold)]),
                 forKey: "attributedTitle")
        setValue(NSAttributedString(string: "Please, choose one of the ways",
                                    attributes: [NSAttributedString.Key.font:
                                        UIFont.systemFont(ofSize: 16, weight: .regular)]),
                 forKey: "attributedMessage")
        
        pruneNegativeWidthConstraints()
    }
}
