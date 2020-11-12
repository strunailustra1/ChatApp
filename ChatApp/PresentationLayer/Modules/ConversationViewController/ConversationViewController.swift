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

    private lazy var tableView: UITableView = {
        tableViewDataSourceDelegate.themesManager = themesManager
        tableViewDataSourceDelegate.fetchedResultsController = fetchedResultsController

        let tableView = UITableView(frame: view.frame, style: .plain)
        
        tableView.register(tableViewDataSourceDelegate.cellIdentifierUpcomingUINib,
                           forCellReuseIdentifier: tableViewDataSourceDelegate.cellIdentifierUpcoming)
        tableView.register(tableViewDataSourceDelegate.cellIdentifierIncomingUINib,
                           forCellReuseIdentifier: tableViewDataSourceDelegate.cellIdentifierIncoming)
        tableView.register(tableViewDataSourceDelegate.sectionHeaderIdentifierUINib,
                           forHeaderFooterViewReuseIdentifier: tableViewDataSourceDelegate.sectionHeaderIdentifier)
        
        tableView.dataSource = tableViewDataSourceDelegate
        tableView.delegate = tableViewDataSourceDelegate
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        
        frcDelegate.tableView = tableView
        
        return tableView
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<MessageDB> = {
        let frc = messageRepository.createFetchedResultsController(channel: channel)
        frc.delegate = frcDelegate
        return frc
    }()
    
    private let notificationCenter = NotificationCenter.default
    
    private var shouldAdjustForKeyboard = false
    private var customInput: InputBarView?
    
    private let messageRepository: MessageRepositoryProtocol
    private let themesManager: ThemesManagerProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let messageAPIManager: MessageAPIManagerProtocol
    private let frcDelegate: ConversationFRCDelegateProtocol
    private let tableViewDataSourceDelegate: ConversationTableViewDataSourceDelegateProtocol
    
    init(messageRepository: MessageRepositoryProtocol,
         themesManager: ThemesManagerProtocol,
         profileRepository: ProfileRepositoryProtocol,
         messageAPIManager: MessageAPIManagerProtocol,
         frcDelegate: ConversationFRCDelegateProtocol,
         tableViewDataSourceDelegate: ConversationTableViewDataSourceDelegateProtocol
    ) {
        self.messageRepository = messageRepository
        self.themesManager = themesManager
        self.profileRepository = profileRepository
        self.messageAPIManager = messageAPIManager
        self.frcDelegate = frcDelegate
        self.tableViewDataSourceDelegate = tableViewDataSourceDelegate
        
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
                if let channel = self?.channel, let profile = self?.profileRepository.profile {
                    self?.messageAPIManager.createMessage(
                        channel: channel,
                        profile: profile,
                        messageText: messageText
                    )
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
