//
//  ProfileTextFieldDelegate.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

protocol TextFieldDelegateWithCompletion: UITextFieldDelegate {
    var endEditingCompletion: ((String?) -> Void)? { get set }
}

class ProfileTextFieldDelegate: NSObject, TextFieldDelegateWithCompletion {
    var endEditingCompletion: ((String?) -> Void)?
}

extension ProfileTextFieldDelegate: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        endEditingCompletion?(textField.text)
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let textFieldString = textField.fullTextWith(range: range, replacementString: string) {
            endEditingCompletion?(textFieldString)
        }
        return true
    }
}
