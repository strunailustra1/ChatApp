//
//  UITextField+Extensions.swift
//  ChatApp
//
//  Created by Наталья Мирная on 14.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

protocol UITextChangedText {
    var currentText: String? { get }
    func fullTextWith(range: NSRange, replacementString: String) -> String?
}

extension UITextChangedText {
    func fullTextWith(range: NSRange, replacementString: String) -> String? {
        if let fullSearchString = self.currentText, let swtRange = Range(range, in: fullSearchString) {
            return fullSearchString.replacingCharacters(in: swtRange, with: replacementString)
        }
        return nil
    }
}

extension UITextField: UITextChangedText {
    var currentText: String? {
        self.text
    }
}

extension UITextView: UITextChangedText {
    var currentText: String? {
        Optional(self.text)
    }
}
