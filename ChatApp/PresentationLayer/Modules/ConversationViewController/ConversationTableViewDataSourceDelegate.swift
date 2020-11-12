//
//  ConversationViewDataSource+Delegate.swift
//  ChatApp
//
//  Created by Наталья Мирная on 10.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol ConversationTableViewDataSourceDelegateProtocol: UITableViewDataSource, UITableViewDelegate {
    var fetchedResultsController: NSFetchedResultsController<MessageDB>? { get set }
    var themesManager: ThemesManagerProtocol? { get set }
    var cellIdentifierUpcoming: String { get }
    var cellIdentifierIncoming: String { get }
    var sectionHeaderIdentifier: String { get }
    var cellIdentifierUpcomingUINib: UINib { get }
    var cellIdentifierIncomingUINib: UINib { get }
    var sectionHeaderIdentifierUINib: UINib { get }
}

class ConversationTableViewDataSourceDelegate: NSObject, ConversationTableViewDataSourceDelegateProtocol {
    var fetchedResultsController: NSFetchedResultsController<MessageDB>?
    var themesManager: ThemesManagerProtocol?
    
    let cellIdentifierUpcoming = String(describing: MessageCell.self) + "Upcoming"
    let cellIdentifierIncoming = String(describing: MessageCell.self) + "Incoming"
    let sectionHeaderIdentifier = String(describing: MessageSectionHeader.self)
    
    var cellIdentifierUpcomingUINib: UINib {
        UINib(nibName: String(describing: MessageCell.self), bundle: nil)
    }
    
    var cellIdentifierIncomingUINib: UINib {
        UINib(nibName: String(describing: MessageCell.self), bundle: nil)
    }
    
    var sectionHeaderIdentifierUINib: UINib {
        UINib(nibName: String(describing: MessageSectionHeader.self), bundle: nil)
    }
}

extension ConversationTableViewDataSourceDelegate: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let messageDB = fetchedResultsController?.object(at: indexPath)
            else { return UITableViewCell() }
        
        let message = Message(messageDB: messageDB)
        
        let cellIdentifier = message.isUpcomingMessage ? cellIdentifierUpcoming : cellIdentifierIncoming
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as? MessageCell
            else { return UITableViewCell() }
        
        cell.configure(with: .init(text: message.content, sender: message.senderName, date: message.created))
        
        cell.bubleView.backgroundColor = message.isUpcomingMessage
            ? themesManager?.getTheme().messageUpcomingBubbleViewColor
            : themesManager?.getTheme().messageIncomingBubbleViewColor
        
        cell.messageLabel.textColor = message.isUpcomingMessage
            ? themesManager?.getTheme().messageUpcomingTextColor
            : themesManager?.getTheme().messageIncomingTextColor
        
        cell.dateLabel.textColor = message.isUpcomingMessage
            ? themesManager?.getTheme().messageDateLabelUpcomingColor
            : themesManager?.getTheme().messageDateLabelIncomingColor
        
        cell.senderNameLabel.textColor = themesManager?.getTheme().messageSenderNameLabelColor
        
        if message.isUpcomingMessage {
            cell.leadingConstraint?.isActive = false
            
            cell.senderNameLabel.isHidden = true
            cell.constraintToSenderNameLabel?.isActive = false
            cell.constraintToViewTop?.constant = 8
        } else {
            cell.trailingConstraint?.isActive = false
            
            cell.senderNameLabel.isHidden = false
            cell.constraintToSenderNameLabel?.isActive = true
            cell.constraintToViewTop?.isActive = false
        }
        
        return cell
    }
}

extension ConversationTableViewDataSourceDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderIdentifier)
            as? MessageSectionHeader
            else { return nil }
        
        guard let sections = fetchedResultsController?.sections else { return nil }
        
        headerView.configure(
            with: .init(title: sections[section].indexTitle ?? ""),
            theme: themesManager?.getTheme()
        )
        
        return headerView
    }
}
