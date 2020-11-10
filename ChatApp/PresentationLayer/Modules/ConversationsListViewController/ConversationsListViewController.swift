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
    
    private let cellIdentifier = String(describing: ConversationCell.self)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UINib(nibName: String(describing: ConversationCell.self), bundle: nil),
                           forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = themesManager.getTheme().tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
        return tableView
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<ChannelDB> = {
        let frc = channelRepository.createFetchedResultsController()
        frc.delegate = self
        return frc
    }()
    
    private lazy var notificationCenter = NotificationCenter.default
    
    private let channelRepository: ChannelRepository
    private let presentationAssembly: PresentationAssemblyProtocol
    private let themesManager: ThemesManagerProtocol
    private let channelAPIManager: ChannelAPIManager
    
    init(
        channelRepository: ChannelRepository,
        presentationAssembly: PresentationAssemblyProtocol,
        themesManager: ThemesManagerProtocol,
        channelAPIManager: ChannelAPIManager
    ) {
        self.channelRepository = channelRepository
        self.presentationAssembly = presentationAssembly
        self.themesManager = themesManager
        self.channelAPIManager = channelAPIManager
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
        fetchedResultsController.delegate = self
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
        if let profileVC = presentationAssembly.profileViewController() {
            profileVC.closeHandler = { [weak self] in
                self?.updateNavigationRightButtonImage()
            }
            let navVC = UINavigationController(rootViewController: profileVC)
            navVC.modalPresentationStyle = .popover
            present(navVC, animated: true, completion: nil)
        }
    }
    
    @objc func editTheme() {
        if let themesVC = presentationAssembly.themesViewController() {
            navigationController?.pushViewController(themesVC, animated: true)
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Channels",
                                                               style: .plain,
                                                               target: nil,
                                                               action: nil)
        }
    }
    
    @objc func addChannel() {
        showAlert(title: "Add new channel", message: "Enter the name of the channel",
                  createActionHandler: { [weak self] (channelName) in
                    self?.channelAPIManager.createChannel(channelName: channelName)
        })
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as? ConversationCell else { return UITableViewCell() }
        
        let channelDB = fetchedResultsController.object(at: indexPath)
        let channel = Channel(channelDB: channelDB)

        cell.configure(with: .init(name: channel.name,
                                   message: channel.lastMessage ?? "",
                                   date: channel.lastActivity))
        return cell
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationVC = presentationAssembly.conversationViewController()
        let channelDB = fetchedResultsController.object(at: indexPath)
        conversationVC.channel = Channel(channelDB: channelDB)
        navigationController?.pushViewController(conversationVC, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        var contextualActions: [UIContextualAction] = []

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {[weak self] _, _, _ in
            guard let channelDBFromMainContext = self?.fetchedResultsController.object(at: indexPath) else { return }
            
            self?.deleteChannelAlert(deleteChannelhandler: { _ in
                self?.channelAPIManager.deleteChannel(channelDBFromMainContext)
            })
        }
        contextualActions.append(deleteAction)
        
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: contextualActions)
        swipeActionsConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeActionsConfiguration
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
        let themesTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.editTheme))
        settingImage.addGestureRecognizer(themesTapGestureRecognizer)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingImage)
    }
    
    func updateNavigationRightButtonImage() {
        if let image = ProfileStorage.shared.profileImage {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            imageView.image = image
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.backgroundColor = UIColor(red: 0.894, green: 0.908, blue: 0.17, alpha: 1)
            imageView.clipsToBounds = true
            imageView.contentMode = imageView.frame.width > imageView.frame.height ? .scaleAspectFit : .scaleAspectFill
            imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            
            let profileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.editProfile))
            imageView.addGestureRecognizer(profileTapGestureRecognizer)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
        } else {
            let button = UIButton(type: .system)
            button.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            button.clipsToBounds = true
            button.setTitle(ProfileStorage.shared.initials, for: .normal)
            button.layer.cornerRadius = button.frame.width / 2
            button.backgroundColor = UIColor(red: 0.894, green: 0.908, blue: 0.17, alpha: 1)
            button.setTitleColor(UIColor(red: 0.212, green: 0.216, blue: 0.22, alpha: 1), for: .normal)
            button.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 22)
            
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

extension ConversationsListViewController: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any, at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .none)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .none)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .none)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .none)
            }
        @unknown default:
            fatalError("undefined type")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension ConversationsListViewController {
    private func deleteChannelAlert(deleteChannelhandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: nil,
                                      message: "Do you really want to delete this channel?",
                                      preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: deleteChannelhandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        alert.pruneNegativeWidthConstraints()
    }
}
