//
//  ProfileTextViewDelegate.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

protocol TextViewDelegateWithCompletion: UITextViewDelegate {
    var endEditingCompletion: ((String?) -> Void)? { get set }
}

class ProfileTextViewDelegate: NSObject, TextViewDelegateWithCompletion {
    var endEditingCompletion: ((String?) -> Void)?
}

extension ProfileTextViewDelegate: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        endEditingCompletion?(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textFieldString = textView.fullTextWith(range: range, replacementString: text) {
            endEditingCompletion?(textFieldString)
        }
        return true
    }
}
