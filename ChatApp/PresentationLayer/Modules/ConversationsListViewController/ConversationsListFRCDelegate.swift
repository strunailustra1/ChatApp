//
//  ConversationsListFRCDelegate.swift
//  ChatApp
//
//  Created by Наталья Мирная on 10.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol ConversationsListFRCDelegateProtocol: NSFetchedResultsControllerDelegate {
    var tableView: UITableView? { get set }
}

class ConversationsListFRCDelegate: NSObject, ConversationsListFRCDelegateProtocol {
    var tableView: UITableView?
}

extension ConversationsListFRCDelegate: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any, at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView?.insertRows(at: [newIndexPath], with: .none)
            }
        case .update:
            if let indexPath = indexPath {
                tableView?.reloadRows(at: [indexPath], with: .none)
            }
        case .move:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .none)
            }
            if let newIndexPath = newIndexPath {
                tableView?.insertRows(at: [newIndexPath], with: .none)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .none)
            }
        @unknown default:
            fatalError("undefined type")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
}
