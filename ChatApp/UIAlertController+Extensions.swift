//
//  UIAlertController+Extensions.swift
//  ChatApp
//
//  Created by Наталья Мирная on 14.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

/*
 https://stackoverflow.com/questions/55653187/swift-default-alertviewcontroller-breaking-constraints/58666480#58666480
 */
extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
