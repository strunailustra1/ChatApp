//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 25.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController {
    
    private let cellIdentifier = String(describing: ConversationCell.self)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UINib(nibName: String(describing: ConversationCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private var conversationList = [[ConversationCell.ConversationCellModel]]()
    
    static func storyboardInstance() -> ConversationsListViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? ConversationsListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conversationList = ConversationProvider.getMessages()
        setupNavigationContoller()
        view.addSubview(tableView)
    }
    
    @objc func editProfile() {
        if let profileVC = ProfileViewController.storyboardInstance() {
            profileVC.closeHandler = { [unowned self] in
                self.setupNavigationContoller()
            }
            let navVC = UINavigationController(rootViewController: profileVC)
            navVC.modalPresentationStyle = .popover
            present(navVC, animated: true, completion: nil)
        }
    }
    
    @objc func themeEdit() {
        if let themesVC = ThemesViewController.storyboardInstance() {
            navigationController?.pushViewController(themesVC, animated: true)
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Tinkoff Chat", style: .plain, target: nil, action: nil)
            themesVC.delegate = ThemesManager.shared
            themesVC.themeChangeHandler = ThemesManager.shared.themeChangeHandler
        }
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversationList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ConversationCell else { return UITableViewCell()}
        cell.configure(with: conversationList[indexPath.section][indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Online" : "History"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        89
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        if let conversationVC = ConversationViewController.storyboardInstance() {
            let conversation = conversationList[indexPath.section][indexPath.row]
            if conversation.message != "" {
                conversationVC.messageList = MessageProvider.getMessages()
            }
            conversationVC.conversation = conversation
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
        navigationItem.title = "Tinkoff Chat"
        
        //   navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        
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
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        }
        
        let settingImage = UIImageView(image: UIImage(named: "Icon Canvas.png"))
        let themesTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.themeEdit))
        settingImage.addGestureRecognizer(themesTapGestureRecognizer)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingImage)
    }
}
