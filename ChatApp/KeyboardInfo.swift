//
//  KeyboardInfo.swift
//  ChatApp
//
//  Created by Наталья Мирная on 21.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

struct KeyboardInfo {
    var animationCurve: UIView.AnimationCurve
    var animationDuration: Double
    var isLocal: Bool
    var frameBegin: CGRect
    var frameEnd: CGRect
}

extension KeyboardInfo {
    init?(_ notification: Notification) {
        guard notification.name == UIResponder.keyboardWillShowNotification
            || notification.name == UIResponder.keyboardWillChangeFrameNotification else { return nil }
        guard let u = notification.userInfo else { return nil }
        
        guard let animationCurve = UIView.AnimationCurve(
            rawValue: u[UIWindow.keyboardAnimationCurveUserInfoKey] as? Int ?? 0
        ) else { return nil }
        self.animationCurve = animationCurve
        
        guard let animationDuration = u[UIWindow.keyboardAnimationDurationUserInfoKey] as? Double else { return nil }
        self.animationDuration = animationDuration
        
        guard let isLocal = u[UIWindow.keyboardIsLocalUserInfoKey] as? Bool else { return nil }
        self.isLocal = isLocal
        
        guard let frameBegin = u[UIWindow.keyboardFrameBeginUserInfoKey] as? CGRect else { return nil }
        self.frameBegin = frameBegin
        
        guard let frameEnd = u[UIWindow.keyboardFrameEndUserInfoKey] as? CGRect else { return nil }
        self.frameEnd = frameEnd
    }
}
