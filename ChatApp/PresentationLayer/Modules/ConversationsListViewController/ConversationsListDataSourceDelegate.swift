//
//  ConversationsListDataSourceDelegate.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol ConversationsListDataSourceDelegateProtocol: UITableViewDataSource, UITableViewDelegate {
    var fetchedResultsController: NSFetchedResultsController<ChannelDB>? { get set }
    var channelAPIManager: ChannelAPIManagerProtocol? { get set }
    var router: RouterProtocol? { get set }
    var controller: UIViewController? { get set }
    var cellIdentifier: String { get }
    var cellIdentifierUINib: UINib { get }
}

class ConversationsListDataSourceDelegate: NSObject, ConversationsListDataSourceDelegateProtocol {
    var fetchedResultsController: NSFetchedResultsController<ChannelDB>?
    var channelAPIManager: ChannelAPIManagerProtocol?
    var router: RouterProtocol?
    weak var controller: UIViewController?
    
    let cellIdentifier = String(describing: ConversationCell.self)
    
    var cellIdentifierUINib: UINib {
        UINib(nibName: String(describing: ConversationCell.self), bundle: nil)
    }
}

extension ConversationsListDataSourceDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as? ConversationCell else { return UITableViewCell() }
        
        guard let channelDB = fetchedResultsController?.object(at: indexPath) else { return UITableViewCell() }
        let channel = Channel(channelDB: channelDB)

        cell.configure(with: .init(name: channel.name,
                                   message: channel.lastMessage ?? "",
                                   date: channel.lastActivity))
        return cell
    }
}
    
extension ConversationsListDataSourceDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navigationController = controller?.navigationController else { return }
        guard let channelDB = fetchedResultsController?.object(at: indexPath) else { return }
        router?.presentConversationVC(in: navigationController, channel: Channel(channelDB: channelDB))
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        var contextualActions: [UIContextualAction] = []

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {[weak self] _, _, _ in
            guard let channelDBFromMainContext = self?.fetchedResultsController?.object(at: indexPath) else { return }
            
            self?.deleteChannelAlert(deleteChannelhandler: { _ in
                self?.channelAPIManager?.deleteChannel(channelDBFromMainContext)
            })
        }
        contextualActions.append(deleteAction)
        
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: contextualActions)
        swipeActionsConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeActionsConfiguration
    }
}

extension ConversationsListDataSourceDelegate {
    private func deleteChannelAlert(deleteChannelhandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: nil,
                                      message: "Do you really want to delete this channel?",
                                      preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: deleteChannelhandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        controller?.present(alert, animated: true, completion: nil)
        alert.pruneNegativeWidthConstraints()
    }
}
