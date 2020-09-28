//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 27.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {
    
    private let cellIdentifierUpcoming = String(describing: MessageCell.self) + "Upcoming"
    private let cellIdentifierIncoming = String(describing: MessageCell.self) + "Incoming"
    private let sectionHeaderIdentifier = String(describing: MessageSectionHeader.self)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UINib(nibName: String(describing: MessageCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifierUpcoming)
        tableView.register(UINib(nibName: String(describing: MessageCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifierIncoming)
        tableView.register(UINib(nibName: String(describing: MessageSectionHeader.self), bundle: nil), forHeaderFooterViewReuseIdentifier: sectionHeaderIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        //todo обрабатывать пустой список сообщений
        
        return tableView
    }()
    
    private lazy var sectionDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMMM d"
        return dateFormatter
    }()
    
    var messageList = [[Message]]()
    
    static func storyboardInstance() -> ConversationViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? ConversationViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if messageList.count > 0 {
            let indexPath = IndexPath(row: messageList[messageList.count - 1].count - 1, section: messageList.count - 1)
            self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: true)
        }
    }
}

extension ConversationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        messageList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messageList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageList[indexPath.section][indexPath.row]
        
        let cellIdentifier = message.isUpcomingMessage ? cellIdentifierUpcoming : cellIdentifierIncoming
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageCell else { return UITableViewCell()}
        
        cell.configure(with: .init(text: message.text))
        
        cell.bubleView.backgroundColor = message.isUpcomingMessage
            ? UIColor(red: 0.863, green: 0.969, blue: 0.773, alpha: 1)
            : UIColor(red: 0.875, green: 0.875, blue: 0.875, alpha: 1)
        
        if message.isUpcomingMessage {
            cell.leadingConstraint?.isActive = false
        } else {
            cell.trailingConstraint?.isActive = false
        }
        
        return cell
    }
}

extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderIdentifier) as? MessageSectionHeader else { return nil }
        
        guard let message = messageList[section].first else { return nil }
        
        headerView.configure(with: .init(date: message.date))
        
        return headerView
    }
}
