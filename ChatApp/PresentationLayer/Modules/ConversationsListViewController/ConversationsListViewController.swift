//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 25.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit
import CoreData

class ConversationsListViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        tableViewDataSourceDelegate.fetchedResultsController = fetchedResultsController
        tableViewDataSourceDelegate.channelAPIManager = channelAPIManager
        tableViewDataSourceDelegate.router = router
        tableViewDataSourceDelegate.controller = self
        
        let tableView = UITableView(frame: view.frame, style: .plain)
        
        tableView.register(tableViewDataSourceDelegate.cellIdentifierUINib,
                           forCellReuseIdentifier: tableViewDataSourceDelegate.cellIdentifier)
        
        tableView.dataSource = tableViewDataSourceDelegate
        tableView.delegate = tableViewDataSourceDelegate
        
        tableView.separatorColor = themesManager.getTheme().tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
        
        frcDelegate.tableView = tableView
        
        return tableView
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<ChannelDB> = {
        let frc = channelRepository.createFetchedResultsController()
        frc.delegate = frcDelegate
        return frc
    }()
    
    private lazy var notificationCenter = NotificationCenter.default
    
    private let router: RouterProtocol
    private let channelRepository: ChannelRepositoryProtocol
    private let themesManager: ThemesManagerProtocol
    private let channelAPIManager: ChannelAPIManagerProtocol
    private let frcDelegate: ConversationsListFRCDelegateProtocol
    private let tableViewDataSourceDelegate: ConversationsListDataSourceDelegateProtocol
    private let profileRepository: ProfileRepositoryProtocol
    
    init(
        router: RouterProtocol,
        channelRepository: ChannelRepositoryProtocol,
        themesManager: ThemesManagerProtocol,
        channelAPIManager: ChannelAPIManagerProtocol,
        frcDelegate: ConversationsListFRCDelegateProtocol,
        tableViewDataSourceDelegate: ConversationsListDataSourceDelegateProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.channelRepository = channelRepository
        self.router = router
        self.themesManager = themesManager
        self.channelAPIManager = channelAPIManager
        self.frcDelegate = frcDelegate
        self.tableViewDataSourceDelegate = tableViewDataSourceDelegate
        self.profileRepository = profileRepository
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        channelAPIManager.removeListener()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        channelAPIManager.deleteMissingChannels()
        
        try? fetchedResultsController.performFetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationContoller()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchedResultsController.delegate = frcDelegate
        channelAPIManager.fetchChannels()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Переходя на экран сообщений отписываемся от всех изменений
        // Warning once only: UITableView was told to layout its visible cells
        // and other contents without being in the view hierarchy
        fetchedResultsController.delegate = nil
        channelAPIManager.removeListener()
    }
    
    @objc func editProfile() {
        router.presentProfileVC(modalFrom: self, closeHandler: { [weak self] in
            self?.updateNavigationRightButtonImage()
        })
    }
    
    @objc func editTheme() {
        guard let navigationController = self.navigationController else { return }
        router.presentThemeVC(in: navigationController)
    }
    
    @objc func addChannel() {
        showAlert(title: "Add new channel", message: "Enter the name of the channel",
                  createActionHandler: { [weak self] (channelName) in
                    self?.channelAPIManager.createChannel(channelName: channelName)
        })
    }
}

extension ConversationsListViewController {
    private func setupNavigationContoller() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: UIFont.Weight.bold)
        ]
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        ]
        navigationItem.title = "Channels"
        updateNavigationRightButtonImage()
        
        let settingImage = themesManager.getTheme().settingImageColor
        settingImage.accessibilityIdentifier = "goToThemesVCElement"
        let themesTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.editTheme))
        settingImage.addGestureRecognizer(themesTapGestureRecognizer)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingImage)
    }
    
    func updateNavigationRightButtonImage() {
        if let image = profileRepository.profile.profileImage {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            imageView.image = image
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.backgroundColor = UIColor(red: 0.894, green: 0.908, blue: 0.17, alpha: 1)
            imageView.clipsToBounds = true
            imageView.contentMode = imageView.frame.width > imageView.frame.height ? .scaleAspectFit : .scaleAspectFill
            imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            imageView.accessibilityIdentifier = "goToProfileVCFromImage"
            
            let profileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.editProfile))
            imageView.addGestureRecognizer(profileTapGestureRecognizer)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
        } else {
            let button = UIButton(type: .system)
            button.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            button.clipsToBounds = true
            button.setTitle(profileRepository.profile.initials, for: .normal)
            button.layer.cornerRadius = button.frame.width / 2
            button.backgroundColor = UIColor(red: 0.894, green: 0.908, blue: 0.17, alpha: 1)
            button.setTitleColor(UIColor(red: 0.212, green: 0.216, blue: 0.22, alpha: 1), for: .normal)
            button.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 22)
            button.accessibilityIdentifier = "goToProfileVCFromButton"
            
            let addButton = UIButton(type: .system)
            addButton.addTarget(self, action: #selector(addChannel), for: .touchUpInside)
            addButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
            addButton.clipsToBounds = true
            addButton.setImage(UIImage(named: "Icon_new_channel"), for: .normal)
            
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: button),
                                                  UIBarButtonItem(customView: addButton)]
        }
    }
}

extension ConversationsListViewController {
    private func showAlert(title: String,
                           message: String,
                           createActionHandler: @escaping ((String) -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            guard let channelName = alert.textFields?.first?.text,
                channelName.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 else {
                    return
            }
            createActionHandler(channelName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField()
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
