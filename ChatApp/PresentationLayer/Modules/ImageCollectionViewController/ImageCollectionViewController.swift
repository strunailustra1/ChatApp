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
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        
        collectionView.register(
            collectionViewDataSourceDelegate.cellIdentifierUINib,
            forCellWithReuseIdentifier: collectionViewDataSourceDelegate.cellIdentifier
        )
        
        collectionView.dataSource = collectionViewDataSourceDelegate
        collectionView.delegate = collectionViewDataSourceDelegate
        
        collectionView.backgroundColor = themesManager.getTheme().profileVCBackgroundColor
        
        collectionViewDataSourceDelegate.collectionView = collectionView
        collectionViewDataSourceDelegate.controller = self
        collectionViewDataSourceDelegate.pixabayService = pixabayService
        collectionViewDataSourceDelegate.changeProfilePhotoDelegate = changeProfilePhotoDelegate
        
        return collectionView
    }()
    
    lazy private var activityIndicator: UIActivityIndicatorView = { [unowned self] in
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.center = view.center
        return activityIndicator
    }()
    
    lazy private var searchController = UISearchController(searchResultsController: nil)
    
    private let model: ImageCollectionModelProtocol
    private let themesManager: ThemesManagerProtocol
    private let pixabayService: PixabayServiceProtocol
    private let collectionViewDataSourceDelegate: ImageCollectionViewDataSourceDelegateProtocol

    private let defaultQuery = "red cat"
    
    weak var changeProfilePhotoDelegate: ChangeProfilePhotoDelegate?
    
    init(
        model: ImageCollectionModelProtocol,
        themesManager: ThemesManagerProtocol,
        pixabayService: PixabayServiceProtocol,
        collectionViewDataSourceDelegate: ImageCollectionViewDataSourceDelegateProtocol
    ) {
        self.model = model
        self.themesManager = themesManager
        self.pixabayService = pixabayService
        self.collectionViewDataSourceDelegate = collectionViewDataSourceDelegate

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.addSubview(activityIndicator)

        setupNavigationController()
        setupSearchBar()
        
        searchImages(by: defaultQuery)
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

extension ImageCollectionViewController: ImageCollectionModelDelegate {
    func searchImages(by query: String) {
        activityIndicator.startAnimating()
        model.searchImages(by: query)
    }
    
    func setup(images: [ImageCollectionCellModel]) {
        DispatchQueue.main.async {
            self.collectionViewDataSourceDelegate.images = images
            self.activityIndicator.stopAnimating()
            self.collectionView.reloadData()
        }
    }
}

extension ImageCollectionViewController: UISearchBarDelegate {
    private func setupSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search query"
        searchController.searchBar.text = defaultQuery
        searchController.searchBar.delegate = self

        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = themesManager.getTheme().labelTextColor
        }
        
        navigationItem.searchController = searchController
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        searchController.isActive = false
        searchController.searchBar.text = query
        
        searchImages(by: query)
    }
}
