//
//  EmblemEmitter.swift
//  ChatApp
//
//  Created by Наталья Мирная on 24.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

class EmblemEmitter {
    private var longPressRecognizer: UILongPressGestureRecognizer?
    private weak var view: UIView?

    private lazy var emblemEmitter = CAEmitterLayer()

    private lazy var emblemCell: CAEmitterCell = {
        let emblemCell = CAEmitterCell()

        emblemCell.contents = UIImage(named: "tinkoff")?.cgImage
        emblemCell.lifetime = 1.0
        emblemCell.birthRate = 20
        emblemCell.scale = 0.03
        emblemCell.scaleRange = 0.3
        emblemCell.emissionLongitude = .pi / 2
        emblemCell.emissionLatitude = 0.0
        emblemCell.emissionRange = .pi / 4
        emblemCell.velocity = 10
        emblemCell.velocityRange = 100
        emblemCell.yAcceleration = 100
        emblemCell.xAcceleration = -550

        return emblemCell
    }()
    
    init(view: UIView?) {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        view?.addGestureRecognizer(longPressRecognizer)
        
        self.view = view
        self.longPressRecognizer = longPressRecognizer
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            setupEmitter()
            emblemEmitter.emitterPosition = sender.location(in: view)
        case .changed:
            emblemEmitter.emitterPosition = sender.location(in: view)
        case .ended, .cancelled:
            emblemEmitter.removeFromSuperlayer()
        default:
            break
        }
    }
    
    private func setupEmitter() {
        emblemEmitter.emitterSize = CGSize(width: 50, height: 50)
        emblemEmitter.emitterShape = .circle
        emblemEmitter.renderMode = .oldestFirst
        emblemEmitter.beginTime = CACurrentMediaTime()
        emblemEmitter.timeOffset = CFTimeInterval(Int.random(in: 1...6) + 5)
        emblemEmitter.emitterCells = [emblemCell]
        view?.layer.addSublayer(emblemEmitter)
    }
}
