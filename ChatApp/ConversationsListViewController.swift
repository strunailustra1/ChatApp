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
    
    private var conversationList = [[ConversationCellModel]]()
    
    static func storyboardInstance() -> ConversationsListViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? ConversationsListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        conversationList = Conversation.getMessages()
        setupNavigationContoller()
    }

    private func setupNavigationContoller() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Tinkoff Chat"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: UIFont.Weight.bold)
        ]
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        ]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        

        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = view.frame.width / 2
        imageView.addSubview(button)
        
        button.setTitle("MD", for: .normal)
        button.setTitleColor(UIColor(red: 0, green: 0.478, blue: 1, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        button.backgroundColor = UIColor(red: 0.894, green: 0.908, blue: 0.17, alpha: 1)
        let editButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = editButton
        
//        let button = UIButton(type: .system)
//        button.setImage(UIImage(named: "pencil"), for: UIControl.State.normal)
//        button.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
//        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//
//        let barButton = UIBarButtonItem(customView: button)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "HH", style: .plain, target: self, action: #selector(editProfile))
    }
    
    @objc func editProfile() {
        if let profileVC = ProfileViewController.storyboardInstance(){
            let navVC = UINavigationController(rootViewController: profileVC)
            navigationController?.present(navVC, animated: true, completion: nil)
            navigationController?.modalPresentationStyle = .popover
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
                conversationVC.messageList = MessageSet.getMessages()
            }
            conversationVC.conversation = conversation
            navigationController?.pushViewController(conversationVC, animated: true)
        }
    }
}
