//
//  InputBarView.swift
//  ChatApp
//
//  Created by Наталья Мирная on 19.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class InputBarView: UIView {
    
    @IBOutlet weak var customInputView: UIView!
    @IBOutlet weak var textInputView: UITextView!
    @IBOutlet weak var sendMessageButton: UIView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var placeholderText: UILabel!
    
    var sendMessageHandler: ((String) -> Void)?
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        sendMessageHandler?(textInputView.text)
        
        sendMessageButton.isHidden = true
        textInputView.text = ""
        
        changeTextViewHeight()
    }
    
    override var intrinsicContentSize: CGSize {
        return textViewContentSize()
    }
    
    func textViewContentSize() -> CGSize {
        let size = CGSize(width: textInputView.bounds.width,
                          height: CGFloat.greatestFiniteMagnitude)

        let textSize = textInputView.sizeThatFits(size)
        return CGSize(width: bounds.width, height: textSize.height)
    }
    
    func confugureInputView() {
        customInputView.backgroundColor = ThemesManager.shared.getTheme().messageInputBackgroundColor
        textInputView.backgroundColor = ThemesManager.shared.getTheme().messageTextInputBackgroundColor
        textInputView.layer.cornerRadius = 16
        textInputView.layer.borderColor = ThemesManager.shared.getTheme().messageTextInputBorderColor
        textInputView.layer.borderWidth = 0.5
        sendMessageButton.isHidden = true
        placeholderText.text = "Your message here..."
        placeholderText.textColor = UIColor.lightGray
        
        textInputView.delegate = self
    }
    
    func changeTextViewHeight() {
        let contentHeight = textViewContentSize().height
        if textViewHeight.constant != contentHeight {
            textViewHeight.constant = textViewContentSize().height
            layoutIfNeeded()
        }
    }
}

extension InputBarView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderText.isHidden = !textView.text.isEmpty
        changeTextViewHeight()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if let textFieldString = textView.fullTextWith(range: range, replacementString: text) {
        if textFieldString.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            sendMessageButton.isHidden = false
            return true
        }
    }
        sendMessageButton.isHidden = true
        return true
    }
}
