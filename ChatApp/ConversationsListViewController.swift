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
        self.tableView.rowHeight = 89
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
}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        if let conversationVC = ConversationViewController.storyboardInstance() {
            let conversation = conversationList[indexPath.section][indexPath.row]
            if conversation.message != "" {
               conversationVC.messageList = MessageSet.getMessages()
            }
            navigationController?.pushViewController(conversationVC, animated: true)
        }
    }
}

