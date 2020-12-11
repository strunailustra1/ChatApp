//
//  ShakeAnimation.swift
//  ChatApp
//
//  Created by Наталья Мирная on 23.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

class ShakeAnimation {
    static func startShaking(for view: UIView,
                             angleDeg: CGFloat = 18,
                             distance: CGFloat = 5,
                             duration: CFTimeInterval = 0.3) {
        
        let angle: CGFloat = angleDeg * .pi / 180
        
        let rotating = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotating.values = [-angle, 0, angle]
        rotating.keyTimes = [0, 0.5, 1.0]
        
        let jumping = CAKeyframeAnimation(keyPath: "transform.translation.y")
        jumping.values = [0, distance, 0.0, -distance]
        jumping.keyTimes = [0, 0.4, 0.8, 1.0]
        
        let sliding = CAKeyframeAnimation(keyPath: "transform.translation.x")
        sliding.values = [0, -distance, 0.0, distance]
        sliding.keyTimes = [0, 0.4, 0.8, 1.0]
        
        let group = CAAnimationGroup()
        group.duration = duration
        group.repeatCount = .infinity
        group.autoreverses = true
        group.animations = [rotating, jumping, sliding]
        
        view.layer.add(group, forKey: "groupAnimation")
    }

    static func stopShaking(for view: UIView, duration: CFTimeInterval = 0.3) {
        
        view.layer.removeAnimation(forKey: "groupAnimation")
        
        let rotating = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotating.values = [view.layer.presentation()?.value(forKeyPath: "transform.rotation.z") ?? 0, 0]
        rotating.keyTimes = [0, 1.0]
        
        let jumping = CAKeyframeAnimation(keyPath: "transform.translation.y")
        jumping.values = [view.layer.presentation()?.value(forKeyPath: "transform.translation.y") ?? 0, 0]
        jumping.keyTimes = [0, 1.0]
        
        let sliding = CAKeyframeAnimation(keyPath: "transform.translation.x")
        sliding.values = [view.layer.presentation()?.value(forKeyPath: "transform.translation.x") ?? 0, 0]
        sliding.keyTimes = [0, 1.0]
        
        let group = CAAnimationGroup()
        group.duration = duration
        group.repeatCount = 1
        group.autoreverses = false
        group.isRemovedOnCompletion = true
        group.animations = [rotating, jumping, sliding]

        view.layer.add(group, forKey: "groupAnimationBack")
    }
}
