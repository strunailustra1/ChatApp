//
//  ImageCollectionController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 16.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

class ImageCollectionViewController: UIViewController {

    let cellIdentifier = String(describing: ImageCollectionViewCell.self)
    let itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.register(
            UINib(nibName: String(describing: ImageCollectionViewCell.self), bundle: nil),
            forCellWithReuseIdentifier: cellIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    lazy private var activityIndicator: UIActivityIndicatorView = { [unowned self] in
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.center = view.center
        return activityIndicator
    }()
    
    private let themesManager: ThemesManagerProtocol
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let defaultQuery = "john snow"
    
    var didSelectItemCompletion: ((UIImage) -> Void)?
    private var result: ApiResult?
    
    init(themesManager: ThemesManagerProtocol) {
        self.themesManager = themesManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.addSubview(activityIndicator)
        collectionView.backgroundColor = themesManager.getTheme().profileVCBackgroundColor
        
        setupNavigationController()
        setupSearchBar()
        
        fetchData(query: defaultQuery)
    }
    
    private func fetchData(query: String) {
        activityIndicator.startAnimating()
        NetworkManager.shared.fetchImages(query: query, succesfullCompletion: { [weak self] (result) in
            DispatchQueue.main.async {
                self?.result = result
                self?.activityIndicator.stopAnimating()
                self?.collectionView.reloadData()
            }
        }, errorCompletion: nil)
    }
    
    private func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                                 width: collectionView.bounds.width,
                                                 height: collectionView.bounds.height))
        messageLabel.text = message
        messageLabel.textColor = themesManager.getTheme().labelTextColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        messageLabel.sizeToFit()
        
        collectionView.backgroundView = messageLabel
    }
    
    private func restore() {
        collectionView.backgroundView = nil
    }
    
    private func setupNavigationController() {
        navigationItem.title = "Images"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(closeImageVC))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)],
            for: .normal)
    }
    
    @objc private func closeImageVC() {
        dismiss(animated: true, completion: nil)
    }
}

extension ImageCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = result?.hits?.count else { return 0 }
        
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
        // cell.configure(with: result)
        print(result?.hits?[indexPath.row].webformatURL)
        if let image = result?.hits?[indexPath.row] {
            cell.configure(with: image)
        }
        return cell
    }
}

extension ImageCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
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
        
        dismiss(animated: true, completion: { [weak self] in
            self?.didSelectItemCompletion?(image)
        })
    }
}

extension ImageCollectionViewController: UISearchBarDelegate {
    private func setupSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search query"
        searchController.searchBar.text = defaultQuery
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    private func search(for searchText: String?) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        searchController.isActive = false
        fetchData(query: query)
    }
}
