//
//  ImageCollectionViewDataSourceDelegate.swift
//  ChatApp
//
//  Created by Наталья Мирная on 19.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

protocol ImageCollectionViewDataSourceDelegateProtocol: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var images: [ImageCollectionCellModel]? { get set }
    var pixabayService: PixabayServiceProtocol? { get set }
    var changeProfilePhotoDelegate: ChangeProfilePhotoDelegate? { get set }
    var collectionView: UICollectionView? { get set }
    var controller: UIViewController? { get set }
    var cellIdentifier: String { get }
    var cellIdentifierUINib: UINib { get }
}

class ImageCollectionViewDataSourceDelegate: NSObject, ImageCollectionViewDataSourceDelegateProtocol {
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)

    var images: [ImageCollectionCellModel]?
    var pixabayService: PixabayServiceProtocol?
    weak var changeProfilePhotoDelegate: ChangeProfilePhotoDelegate?
    weak var collectionView: UICollectionView?
    weak var controller: UIViewController?
    
    let cellIdentifier = String(describing: ImageCollectionViewCell.self)
    
    var cellIdentifierUINib: UINib {
        UINib(nibName: String(describing: ImageCollectionViewCell.self), bundle: nil)
    }
}

extension ImageCollectionViewDataSourceDelegate {
    private func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                                 width: collectionView?.bounds.width ?? 0,
                                                 height: collectionView?.bounds.height ?? 0))
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        messageLabel.sizeToFit()
        
        collectionView?.backgroundView = messageLabel
    }
    
    private func restore() {
        collectionView?.backgroundView = nil
    }
}

extension ImageCollectionViewDataSourceDelegate: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = images?.count else { return 0 }
        
        if count == 0 {
            setEmptyMessage("Nothing to show")
        } else {
            restore()
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            as? ImageCollectionViewCell else { return UICollectionViewCell() }
        
        if let image = images?[indexPath.row] {
            cell.configure(with: image, pixabayService: pixabayService)
        
        }
        return cell
    }
}

extension ImageCollectionViewDataSourceDelegate: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let controller = controller else { return CGSize() }
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = controller.view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else { return }
        guard let image = cell.imageView.image else { return }
        
        controller?.dismiss(animated: true, completion: { [weak self] in
            self?.changeProfilePhotoDelegate?.changeProfilePhoto(image)
        })
    }
}
