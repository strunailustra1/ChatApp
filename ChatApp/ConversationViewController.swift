//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 27.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit
import Firebase

struct MessageFire {
    let content: String
    let created: Date
    let senderId: String
    let senderName: String
    
    var stringDay: String {
        MessageFire.dayDateFormatter.string(from: created)
    }
    
    var isUpcomingMessage: Bool {
        senderId == UIDevice.current.identifierForVendor?.uuidString
    }

    static var dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    init(content: String) {
        self.content = content
        created = Date()
        senderId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        senderName = ProfileStorage.shared.fullname
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let content = data["content"] as? String,
            let created = data["created"] as? Timestamp,
            let senderId = data["senderId"] as? String,
            let senderName = data["senderName"] as? String
            else { return nil }
        
        self.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        self.created = created.dateValue()
        self.senderId = senderId
        self.senderName = senderName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension MessageFire: DatabaseRepresentation {
    var representation: [String: Any] {
        return [
            "content": content,
            "created": Timestamp(date: created),
            "senderId": senderId,
            "senderName": senderName
        ]
    }
}
extension MessageFire: Comparable {
    static func < (lhs: MessageFire, rhs: MessageFire) -> Bool {
        return lhs.created < rhs.created
    }
}

class ConversationViewController: UIViewController {
    
    private let cellIdentifierUpcoming = String(describing: MessageCell.self) + "Upcoming"
    private let cellIdentifierIncoming = String(describing: MessageCell.self) + "Incoming"
    private let sectionHeaderIdentifier = String(describing: MessageSectionHeader.self)
    
    private lazy var tableView: UITableView = {
        //todo view frame height - x px
        //let tableView = UITableView(frame: view.frame, style: .plain)
        let tableView = UITableView(frame: CGRect(x: 0, y: 0,
                                                  width: view.frame.width,
                                                  height: view.frame.height - 94),
                                    style: .plain)
        tableView.register(UINib(nibName: String(describing: MessageCell.self), bundle: nil),
                           forCellReuseIdentifier: cellIdentifierUpcoming)
        tableView.register(UINib(nibName: String(describing: MessageCell.self), bundle: nil),
                           forCellReuseIdentifier: cellIdentifierIncoming)
        tableView.register(UINib(nibName: String(describing: MessageSectionHeader.self), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: sectionHeaderIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    //  private var shouldScrollToBottom = true
    private var customInput: InputBarView?
    
    private let db = Firestore.firestore()
    private var messagesReference: CollectionReference?
    private var messageListener: ListenerRegistration?

    private let notificationCenter = NotificationCenter.default
    
    var messages = [[MessageFire]]()
    var channel: Channel?
    
    deinit {
        messageListener?.remove()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            if customInput == nil {
                customInput = Bundle.main.loadNibNamed("InputBarView", owner: self,
                                                       options: nil)?.first as? InputBarView
                customInput?.confugureInputView()
                customInput?.sendMessageHandler = { [weak self] messageText in
                    let message = MessageFire(content: messageText)
                    self?.save(message)
                    //inputBar.inputTextView.text = ""
                }
            }
            return customInput
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        setupNavigationController()
        
        if let channel = self.channel {
            messagesReference = db.collection("channels").document(channel.identifier).collection("messages")
            
            messageListener = messagesReference?.order(by: "created").addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    self.handleDocumentChange(change)
                }
            }
        }
        
        view.backgroundColor = .red
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }
    
    private func save(_ message: MessageFire) {
        messagesReference?.addDocument(data: message.representation) { error in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }

            //self.messagesCollectionView.scrollToRow()
        }
    }
    
    private func insertNewMessage(_ message: MessageFire) {
        
        var hasSection = false
        for (section, sectionMessages) in messages.enumerated() {
            if let firstMessage = sectionMessages.first, firstMessage.stringDay == message.stringDay {
                messages[section].append(message)
                hasSection = true
                
                tableView.insertRows(at: [IndexPath(row: messages[section].count - 1,
                                                    section: section)],
                                     with: .automatic)
                
                break
            }
        }
        
        if !hasSection {
            messages.append([message])
            let section = IndexSet(integer: messages.count - 1)
            tableView.insertSections(section, with: .automatic)
        }
        
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages[messages.count - 1].count - 1,
                                      section: messages.count - 1)
            tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: true)
//            DispatchQueue.main.async {
//                self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: false)
//            }
        }
        
        //      if shouldScrollToBottom {
        //        DispatchQueue.main.async {
        //          self.messagesCollectionView.scrollToBottom(animated: true)
        //        }
        //      }
        
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = MessageFire(document: change.document) else {
            return
        }

        switch change.type {
        case .added:
            insertNewMessage(message)
        default:
          break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
        
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillShow(sender:)),
                                       name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillHide(sender:)),
                                       name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //        print(tableView.frame)
        //        if shouldScrollToBottom {
        //            shouldScrollToBottom = false
        //            scrollToBottom(animated: false)
        //        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //    private func scrollToBottom(animated: Bool) {
    //        view.layoutIfNeeded()
    //        tableView.setContentOffset(bottomOffset(), animated: animated)
    //    }
    //
    //    private func bottomOffset() -> CGPoint {
    //        print(-tableView.contentInset.top,
    //               tableView.contentSize.height,
    //               tableView.bounds.size.height, tableView.contentInset.bottom)
    //        return CGPoint(x: 0,
    //                       y: max(-tableView.contentInset.top,
    //                              tableView.contentSize.height -
    //                                (tableView.bounds.size.height - tableView.contentInset.bottom)))
    //    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y = keyboardSize.height > 226 ? -250 : -keyboardSize.height
            }
        }
        //        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
        //            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        //           }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
        //        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
        //            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //        }
    }
    
    //    func adjustContentForKeyboard(shown: Bool, notification: NSNotification) {
    //        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
    //            let keyboardHeight = shown ? keyboardSize.size.height : customInput?.bounds.size.height ?? 0
    //            if tableView.contentInset.bottom == keyboardHeight {
    //                return
    //            }
    //
    //            let distanceFromBottom = bottomOffset().y - tableView.contentOffset.y
    //            var insets = tableView.contentInset
    //            insets.bottom = keyboardHeight
    //
    //            self.tableView.contentInset = insets
    //            self.tableView.scrollIndicatorInsets = insets
    //
    //             if distanceFromBottom < 10 {
    //                self.tableView.contentOffset = self.bottomOffset()
    //             }
    //        }
    //    }
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
        
        cell.configure(with: .init(text: message.content, sender: message.senderName))
        
        cell.bubleView.backgroundColor = message.isUpcomingMessage
            ? ThemesManager.shared.getTheme().messageUpcomingBubbleViewColor
            : ThemesManager.shared.getTheme().messageIncomingBubbleViewColor
        
        cell.messageLabel.textColor = message.isUpcomingMessage
            ? ThemesManager.shared.getTheme().messageUpcomingTextColor
            : ThemesManager.shared.getTheme().messageIncomingTextColor
        
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
