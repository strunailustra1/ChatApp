//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 25.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit
import Firebase

class ConversationsListViewController: UIViewController {
    
    private let cellIdentifier = String(describing: ConversationCell.self)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UINib(nibName: String(describing: ConversationCell.self), bundle: nil),
                           forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = ThemesManager.shared.getTheme().tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
        return tableView
    }()
    
    private lazy var notificationCenter = NotificationCenter.default
    
    private var channels = [Channel]()
    
    static func storyboardInstance() -> ConversationsListViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? ConversationsListViewController
    }
    
    deinit {
        FirestoreDataProvider.shared.removeChannelsListener()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationContoller()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FirestoreDataProvider.shared.getChannels(completion: { [weak self] change in
            self?.handleDocumentChange(change)
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // костыль для подавления ворнинга
        // не очень хорошо отключать обновление данных,
        // но пока не понятно как тогда подавлять обновление интерфейса ConversationListVC, находясь на ConversationVC
        // UITableView was told to layout its visible cells and other contents without being in the view hierarchy
        FirestoreDataProvider.shared.removeChannelsListener()
    }
    
    @objc func editProfile() {
        if let profileVC = ProfileViewController.storyboardInstance() {
            profileVC.closeHandler = { [weak self] in
                self?.updateNavigationRightButtonImage()
            }
            let navVC = UINavigationController(rootViewController: profileVC)
            navVC.modalPresentationStyle = .popover
            present(navVC, animated: true, completion: nil)
        }
    }
    
    @objc func editTheme() {
        if let themesVC = ThemesViewController.storyboardInstance() {
            navigationController?.pushViewController(themesVC, animated: true)
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Channels",
                                                               style: .plain,
                                                               target: nil,
                                                               action: nil)
            themesVC.delegate = ThemesManager.shared
            themesVC.themeChangeHandler = ThemesManager.shared.themeChangeHandler
        }
    }
    
    @objc func addChannel() {
        showAlert(title: "Add new channel", message: "Enter the name of the channel",
                  createActionHandler: { [weak self] (channelName) in
                    self?.createChannel(channelName: channelName)
        })
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as? ConversationCell else { return UITableViewCell() }
        
        let channel = channels[indexPath.row]
        cell.configure(with: .init(name: channel.name,
                                   message: channel.lastMessage ?? "",
                                   date: channel.lastActivity))
        return cell
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        if let conversationVC = ConversationViewController.storyboardInstance() {
            let channel = channels[indexPath.row]
            conversationVC.channel = channel
            navigationController?.pushViewController(conversationVC, animated: true)
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
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
        
        let settingImage = ThemesManager.shared.getTheme().settingImageColor
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

extension ConversationsListViewController {
    private func addChannelToTable(_ channel: Channel) {
        guard !channels.contains(channel) else { return }
        
        channels.append(channel)
        channels.sort(by: >)
        
        guard let index = channels.firstIndex(of: channel) else { return }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func updateChannelInTable(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else { return }
        
        channels[index] = channel
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeChannelFromTable(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else { return }
        
        channels.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let channel = Channel(document: change.document) else { return }
        
        switch change.type {
        case .added:
            addChannelToTable(channel)
            
        case .modified:
            updateChannelInTable(channel)
            
        case .removed:
            removeChannelFromTable(channel)
        }
    }

    private func createChannel(channelName: String) {
        let channel = Channel(name: channelName)
        self.addChannelToTable(channel)
        // создаем документ со своим id, т.к. предварительно сами помещаем его наверх таблицы
        // неплохо было бы в api иметь поле с максимальной из двух дат (дата создания канала или последнего сообщения),
        // чтобы сортировать по данной дате список каналов, но такого пока нет, поэтому костылим
        FirestoreDataProvider.shared.createChannel(channel: channel) { [weak self] _ in
            self?.removeChannelFromTable(channel)
        }
    }
}
