//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 27.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit
import CoreData

class ConversationViewController: UIViewController {
    
    private let cellIdentifierUpcoming = String(describing: MessageCell.self) + "Upcoming"
    private let cellIdentifierIncoming = String(describing: MessageCell.self) + "Incoming"
    private let sectionHeaderIdentifier = String(describing: MessageSectionHeader.self)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        
        tableView.register(UINib(nibName: String(describing: MessageCell.self), bundle: nil),
                           forCellReuseIdentifier: cellIdentifierUpcoming)
        tableView.register(UINib(nibName: String(describing: MessageCell.self), bundle: nil),
                           forCellReuseIdentifier: cellIdentifierIncoming)
        tableView.register(UINib(nibName: String(describing: MessageSectionHeader.self), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: sectionHeaderIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        
        return tableView
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<MessageDB> = {
        let frc = messageRepository.createFetchedResultsController(channel: channel)
        frc.delegate = self
        return frc
    }()
    
    private let notificationCenter = NotificationCenter.default
    
    private var shouldAdjustForKeyboard = false
    private var customInput: InputBarView?
    
    private let messageRepository: MessageRepository
    private let themesManager: ThemesManagerProtocol
    private let messageAPIManager: MessageAPIManager
    
    init(messageRepository: MessageRepository,
         themesManager: ThemesManagerProtocol,
         messageAPIManager: MessageAPIManager
    ) {
        self.messageRepository = messageRepository
        self.themesManager = themesManager
        self.messageAPIManager = messageAPIManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var inputAccessoryView: UIView? {
        if customInput == nil {
            customInput = Bundle.main.loadNibNamed("InputBarView", owner: self,
                                                   options: nil)?.first as? InputBarView
            customInput?.configure(with: .init(), theme: themesManager.getTheme())
            customInput?.sendMessageHandler = { [weak self] messageText in
                if let channel = self?.channel {
                    self?.messageAPIManager.createMessage(channel: channel, messageText: messageText)
                }
            }
        }
        return customInput
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var canResignFirstResponder: Bool {
        return true
    }
    
    var channel: Channel?
    
    deinit {
        messageAPIManager.removeListener()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        setupNavigationController()
        
        try? fetchedResultsController.performFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        becomeFirstResponder()
        hideKeyboardWhenTappedAround()
        registerKeyboardNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollToBottom(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let channel = self.channel {
            messageAPIManager.fetchMessages(channel: channel, completion: { [weak self] in
                self?.scrollToBottom(animated: false)
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterKeyboardNotifications()
    }
}

extension ConversationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageDB = fetchedResultsController.object(at: indexPath)
        let message = Message(messageDB: messageDB)
        
        let cellIdentifier = message.isUpcomingMessage ? cellIdentifierUpcoming : cellIdentifierIncoming
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as? MessageCell
            else { return UITableViewCell()}
        
        cell.configure(with: .init(text: message.content, sender: message.senderName, date: message.created))
        
        cell.bubleView.backgroundColor = message.isUpcomingMessage
            ? themesManager.getTheme().messageUpcomingBubbleViewColor
            : themesManager.getTheme().messageIncomingBubbleViewColor
        
        cell.messageLabel.textColor = message.isUpcomingMessage
            ? themesManager.getTheme().messageUpcomingTextColor
            : themesManager.getTheme().messageIncomingTextColor
        
        cell.dateLabel.textColor = message.isUpcomingMessage
            ? themesManager.getTheme().messageDateLabelUpcomingColor
            : themesManager.getTheme().messageDateLabelIncomingColor
        
        cell.senderNameLabel.textColor = themesManager.getTheme().messageSenderNameLabelColor
        
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

extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderIdentifier)
            as? MessageSectionHeader
            else { return nil }
        guard let sections = fetchedResultsController.sections else { return nil }
        
        headerView.configure(with: .init(title: sections[section].indexTitle ?? ""), theme: themesManager.getTheme())
        return headerView
    }
}

extension ConversationViewController {
    private func setupNavigationController() {
        navigationItem.title = channel?.name
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            NSAttributedString.Key.foregroundColor: themesManager.getTheme().navigationTitleColor
        ]
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

extension ConversationViewController {
    private func scrollToBottom(animated: Bool) {
        view.layoutIfNeeded()
        tableView.setContentOffset(bottomOffset(), animated: animated)
    }
    
    private func bottomOffset() -> CGPoint {
        CGPoint(
            x: 0,
            y: max(-tableView.contentInset.bottom - 10,
                   tableView.contentSize.height - (tableView.bounds.size.height - tableView.contentInset.bottom))
        )
    }
}

extension ConversationViewController {
    private func registerKeyboardNotifications() {
        shouldAdjustForKeyboard = true
        
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillShow(sender:)),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillHide(sender:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
    }
    
    private func unregisterKeyboardNotifications() {
        shouldAdjustForKeyboard = false
        
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func adjustContentForKeyboard(shown: Bool, notification: NSNotification) {
        guard shouldAdjustForKeyboard, let payload = KeyboardInfo(notification as Notification) else { return }
        
        let keyboardHeight = shown ? payload.frameEnd.size.height : customInput?.bounds.size.height ?? 0
        if tableView.contentInset.bottom == keyboardHeight {
            return
        }
        
        let distanceFromBottom = bottomOffset().y - tableView.contentOffset.y
        
        var insets = tableView.contentInset
        insets.bottom = keyboardHeight
        
        UIView.animate(withDuration: payload.animationDuration, delay: 0, options: .curveEaseIn, animations: {
            
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
            
            if distanceFromBottom < 10 {
                self.tableView.contentOffset = self.bottomOffset()
            }
        }, completion: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        adjustContentForKeyboard(shown: true, notification: sender)
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        adjustContentForKeyboard(shown: false, notification: sender)
    }
}

extension ConversationViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    /*
     Не удалось побороть, view.endEditing(true) тоже не помог (не работает)
     First responder warning: '<UITextView: 0x7fe567077e00;'
     rejected resignFirstResponder when being removed from hierarchy
     */
    @objc func dismissKeyboard() {
        customInput?.textInputView.resignFirstResponder()
    }
}

extension ConversationViewController: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        sectionIndexTitleForSectionName sectionName: String
    ) -> String? {
        return sectionName
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        @unknown default:
            fatalError("undefined type")
        }
    }
    
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
