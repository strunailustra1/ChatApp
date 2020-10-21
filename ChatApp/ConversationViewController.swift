//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 27.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit
import Firebase

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
    
    private let notificationCenter = NotificationCenter.default
    
    private var shouldAdjustForKeyboard = false
    private var customInput: InputBarView?
    
    override var inputAccessoryView: UIView? {
        if customInput == nil {
            customInput = Bundle.main.loadNibNamed("InputBarView", owner: self,
                                                   options: nil)?.first as? InputBarView
            customInput?.confugureInputView()
            customInput?.sendMessageHandler = { [weak self] messageText in
                let message = Message(content: messageText)
                self?.saveMessage(message)
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
    
    static func storyboardInstance() -> ConversationViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? ConversationViewController
    }
    
    var messages = [[Message]]()
    var channel: Channel?
    
    deinit {
        FirestoreDataProvider.shared.removeMessagesListener()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        setupNavigationController()
        
        if let channel = self.channel {
            FirestoreDataProvider.shared.getMessages(in: channel, completion: { [weak self] change in
                self?.handleDocumentChange(change)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        becomeFirstResponder()
        hideKeyboardWhenTappedAround()
        registerKeyboardNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterKeyboardNotifications()
    }
}

extension ConversationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.section][indexPath.row]
        
        let cellIdentifier = message.isUpcomingMessage ? cellIdentifierUpcoming : cellIdentifierIncoming
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as? MessageCell
            else { return UITableViewCell()}
        
        cell.configure(with: .init(text: message.content, sender: message.senderName, date: message.created))
        
        cell.bubleView.backgroundColor = message.isUpcomingMessage
            ? ThemesManager.shared.getTheme().messageUpcomingBubbleViewColor
            : ThemesManager.shared.getTheme().messageIncomingBubbleViewColor
        
        cell.messageLabel.textColor = message.isUpcomingMessage
            ? ThemesManager.shared.getTheme().messageUpcomingTextColor
            : ThemesManager.shared.getTheme().messageIncomingTextColor
        
        cell.dateLabel.textColor = message.isUpcomingMessage
            ? ThemesManager.shared.getTheme().messageDateLabelUpcomingColor
            : ThemesManager.shared.getTheme().messageDateLabelIncomingColor
        
        cell.senderNameLabel.textColor = ThemesManager.shared.getTheme().messageSenderNameLabelColor
        
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
        
        guard let message = messages[section].first else { return nil }
        
        headerView.configure(with: .init(date: message.created))
        
        return headerView
    }
}

extension ConversationViewController {
    private func setupNavigationController() {
        navigationItem.title = channel?.name
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            NSAttributedString.Key.foregroundColor: ThemesManager.shared.getTheme().navigationTitleColor
        ]
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

extension ConversationViewController {
    private func saveMessage(_ message: Message) {
        guard let channel = self.channel else { return }
        FirestoreDataProvider.shared.createMessage(in: channel, message: message)
    }
    
    private func insertNewMessage(_ message: Message) {
        
        var hasSection = false
        for (section, sectionMessages) in messages.enumerated() {
            if let firstMessage = sectionMessages.first, firstMessage.stringDay == message.stringDay {
                messages[section].append(message)
                hasSection = true
                
                tableView.insertRows(at: [IndexPath(row: messages[section].count - 1,
                                                    section: section)],
                                     with: .none)
                break
            }
        }
        
        if !hasSection {
            messages.append([message])
            let section = IndexSet(integer: messages.count - 1)
            tableView.insertSections(section, with: .none)
        }
        
        scrollToBottom(animated: false)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            insertNewMessage(message)
        default:
            break
        }
    }
    
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
