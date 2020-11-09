//
//  InputBarView.swift
//  ChatApp
//
//  Created by Наталья Мирная on 19.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class InputBarView: UIView, ConfigurableView {
    typealias ConfigurationModel = InputBarModel
    
    struct InputBarModel {
    }
    
    @IBOutlet weak var customInputView: UIView!
    @IBOutlet weak var textInputView: UITextView!
    @IBOutlet weak var sendMessageButton: UIView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var placeholderText: UILabel!
    
    let maxTextViewHeight: CGFloat = 100
    
    var sendMessageHandler: ((String) -> Void)?
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        sendMessageHandler?(textInputView.text)
        
        sendMessageButton.isHidden = true
        textInputView.text = ""
        
        changeTextViewHeight()
    }
    
    /*
     не удалось победить warning
     хотя на so предлагают именно такое решение https://stackoverflow.com/a/45744784
     API error: <_UIKBCompatInputView: 0x7fa61eca7f50; frame = (0 0; 0 0);
     layer = <CALayer: 0x600003339da0>> returned 0 width, assuming UIViewNoIntrinsicMetric
     */
    override var intrinsicContentSize: CGSize {
        return textViewContentSize()
    }
    
    func configure(with model: InputBarModel, theme: Theme?) {
        customInputView.backgroundColor = theme?.messageInputBackgroundColor
        textInputView.backgroundColor = theme?.messageTextInputBackgroundColor
        textInputView.layer.cornerRadius = 16
        textInputView.layer.borderColor = theme?.messageTextInputBorderColor
        textInputView.layer.borderWidth = 0.5
        textInputView.textColor = theme?.labelTextColor
        textInputView.delegate = self
        
        sendMessageButton.isHidden = true
        
        placeholderText.text = "Your message here..."
        placeholderText.textColor = UIColor.lightGray
    }
    
    private func textViewContentSize() -> CGSize {
        let size = CGSize(width: textInputView.bounds.width,
                          height: CGFloat.greatestFiniteMagnitude)
        
        let textSize = textInputView.sizeThatFits(size)
        
        return CGSize(width: bounds.width,
                      height: textSize.height > maxTextViewHeight ? maxTextViewHeight : textSize.height)
    }
    
    private func changeTextViewHeight() {
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
