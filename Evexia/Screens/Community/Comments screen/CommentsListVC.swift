//
//  CommentsListVC.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 26.09.2021.
//

import UIKit
import Combine
import CRRefresh
import Atributika

// MARK: - CommentsListVC
class CommentsListVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentTextView: TaggingTextView!
    @IBOutlet weak var contentViewTextView: UIView!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightTextView: NSLayoutConstraint!
    @IBOutlet weak var textViewPlaceHolderLabel: UILabel!
    @IBOutlet weak var companyUsersTable: UITableView!
    @IBOutlet weak var tableWrapView: UIView!
    @IBOutlet weak var usersTableHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    var viewModel: CommentsListVMType!
    private let playVideoPublisher = PassthroughSubject<Void, Never>()
    private let appear = PassthroughSubject<Void, Never>()
    private let loadComments = PassthroughSubject<Void, Never>()
    private let updateComments = PassthroughSubject<Void, Never>()
    private let addReply = PassthroughSubject<(String, String, ReplyToModel, [String]), Never>()
    private let createComment = PassthroughSubject<(String, [String]), Never>()
    private let addRemoveLikePublisher = PassthroughSubject<String, Never>()
    private let dismissSocialWebView = PassthroughSubject<Int?, Never>()
    private var cancellables = Set<AnyCancellable>()
    private lazy var commentsDataSource = configureCommentsDataSource()
    private lazy var usersDataSource = configureUsersDataSource()
    private lazy var tableHeaderView = createHeaderView()
    private var isReplyState = false
    private var commentId = ""
    private var replyId = ""
    private var cellIndex = IndexPath(row: 0, section: 0)
    private var keyboardIsShow = false
    private var commentAuthor = ""
    private var replyToModel: ReplyToModel?
    
    private var userAttributes: Style {
        return Style()
            .foregroundColor(.orange, .normal)
            .foregroundColor(.orange, .highlighted)
            .font(UIFont(name: "NunitoSans-Bold", size: 16.0)!)
    }
    
    private var plainAttributes: Style {
        return Style
            .foregroundColor(.gray900, .normal)
            .font(UIFont(name: "NunitoSans-Regular", size: 16.0)!)
        
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(to: viewModel)
        bindWithHeaderView()
        appear.send()
        handleHeightKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playVideoPublisher.send()
    }
    
    // MARK: - IBOutlets
    @IBAction func closeVC() {
        if !commentTextView.text.isEmpty {
            modalAlert(modalStyle: ModalAlertViewStyles.notChangedEditPost, completion: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }, cancel: { })
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addCommentOrReply() {
        let text = commentTextView.getTaggedText()
        let result = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\n{2,}", with: "\n", options: .regularExpression)
        if isReplyState, let replyModel = replyToModel {
            addReply.send((result, commentId, replyModel, commentTextView.savedTags))
        } else {
            createComment.send((result, commentTextView.savedTags))
        }
    }
}

// MARK: - Bind and render
extension CommentsListVC {
    
    func bind(to viewModel: CommentsListVMType) {
        
        let input = CommentsListVMInput(
            appear: appear.eraseToAnyPublisher(),
            loadComments: loadComments.eraseToAnyPublisher(),
            addReply: addReply.eraseToAnyPublisher(),
            createComment: createComment.eraseToAnyPublisher(),
            addRemoveLikePublisher: addRemoveLikePublisher.eraseToAnyPublisher(),
            updateComments: updateComments.eraseToAnyPublisher()
        )
        let output = viewModel.transform(input: input)
        output.sink { [weak self] state in
            self?.render(state)
        }.store(in: &cancellables)
        
        self.viewModel.communityUsers
            .sink(receiveValue: { [weak self] users in
                self?.updateUsersTable(with: users)
            }).store(in: &cancellables)

        commentTextView.searchText
            .sink(receiveValue: { [weak self] search in
                switch search {
                case let .search(text):
                    self?.viewModel.searchUsers(text)
                case .stop:
                    self?.viewModel.communityUsers.send([])
                }
            }).store(in: &cancellables)
    }
    
    private func updateUsersTable(with users: [CommunityUser]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableWrapView.isHidden = (users.isEmpty && self.commentTextView.text.isEmpty)
            var snapShot = NSDiffableDataSourceSnapshot<Int, CommunityUser>()
            snapShot.appendSections([0])
            snapShot.appendItems(users)
            self.usersDataSource.apply(snapShot, animatingDifferences: false)
            
            if users.count > 4 {
                self.usersTableHeight.constant = 4 * 68.0
                self.companyUsersTable.isScrollEnabled = true
            } else {
                self.usersTableHeight.constant = Double(users.count) * 68.0
                self.companyUsersTable.isScrollEnabled = false

            }
        }
    }
    
    func render(_ state: CommentsListVCState) {
        switch state {
        case let .idle(post):
            configTableHeaderView(post: post)
            loadComments.send()
            commentsTableView.showActivityIndicator()
        case let .failure(error):
            modalAlert(modalStyle: error.errorCode)
        case .addRemoveLike:
            print("Complete SocialAction")
        case let .somePage(comments):
            updateWithComments(with: comments)
            viewModel.isReadyToPagination = true
        case let .lastPage(comments):
            updateWithComments(with: comments)
            viewModel.isReadyToPagination = false
        case let .addComment(comments):
            updateWithComments(with: comments, isScroll: true)
        case let .addReply(comments, replyId):
            self.replyId = replyId
            updateWithComments(with: comments, isScroll: true)
            
        }
    }
    
}

// MARK: - Private Extension
private extension CommentsListVC {
    func setupUI() {
        setupNavView()
        setupContainerView()
        setupCommentsTableView()
        setupPostTextView()
        sendCommentButton.isHidden = true
    }
    
    func setupNavView() {
        navView.layer.cornerRadius = 30
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setupContainerView() {
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setupPostTextView() {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
        commentTextView.typingAttributes = attributes
        commentTextView.delegate = self
        commentTextView.backgroundColor = .gray100
        commentTextView.layer.cornerRadius = 16
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor.gray400.cgColor
        commentTextView.textContainerInset = .init(top: 10, left: 12, bottom: 10, right: 12)
        commentTextView.font = UIFont(name: "NunitoSans-Regular", size: 16.0)!
        commentTextView.textColor = .gray900
    }
    
    func setupCommentsTableView() {
        commentsTableView.clipsToBounds = true
        commentsTableView.layer.cornerRadius = 30
        commentsTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        commentsTableView.delegate = self
        commentsTableView.tableHeaderView = tableHeaderView
        commentsTableView.dataSource = commentsDataSource
        commentsTableView.separatorStyle = .none
        commentsTableView.showsVerticalScrollIndicator = false
        commentsTableView.rowHeight = UITableView.automaticDimension

        commentsTableView.cr.addHeadRefresh { [weak self] in
            self?.appear.send()
        }
        
        commentsTableView.register(CommentsListCell.nib, forCellReuseIdentifier: CommentsListCell.identifier)
        commentsTableView.register(ReplyListCell.nib, forCellReuseIdentifier: ReplyListCell.identifier)
        companyUsersTable.delegate = self
        companyUsersTable.rowHeight = 68
        companyUsersTable.register(CommunityUserCell.nib, forCellReuseIdentifier: CommunityUserCell.identifier)
        companyUsersTable.separatorStyle = .none
    }
    
    // MARK: - HandleHeightKeyboard
    func handleHeightKeyboard() {
        Publishers.keyboardHeightPublisher
            .sink(receiveValue: { [weak self] height, _ in
                guard let self = self else { return }
                self.textViewBottomConstraint.constant = height
                self.view.layoutIfNeeded()
                if height != 0, !self.keyboardIsShow {
                    self.keyboardIsShow = true
                } else if height == 0 {
                    self.keyboardIsShow = false
                }
            }).store(in: &cancellables)
    }
    
    func scrollToBotom(isReplyPublished: Bool = false) {
        let numberCells = self.commentsTableView.numberOfRows(inSection: 0)
        guard numberCells != 0 else { return }
        
        DispatchQueue.main.async {
            if !self.isReplyState {
                let indexPath = IndexPath(row: 0, section: 0)
                UIView.animate(withDuration: 0.3, animations: {
                    self.commentsTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                })
               
            } else if self.isReplyState {
                self.commentsTableView.scrollToRow(at: self.cellIndex, at: .bottom, animated: true)
                if isReplyPublished {
                    self.isReplyState = false
                }
            }
        }
    }
    
    func configTableHeaderView(post: LocalPost) {
        tableHeaderView.cofigureCellModel(model: post, viewType: viewModel.viewType)
        tableHeaderView.playVideoPublisher = playVideoPublisher
        tableHeaderView.widthContentViewConstant.constant = view.frame.width
        tableHeaderView.frame.size.height = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        tableHeaderView.layoutIfNeeded()
    }
    
    func createHeaderView() -> PostView {
        let header = PostView(frame: .zero)
        header.isUserInteractionEnabled = true
        return header
    }
    
    func bindWithHeaderView() {
        tableHeaderView.likePublisher.sink(receiveValue: { [weak self] postId in
            self?.addRemoveLikePublisher.send(postId)
        }).store(in: &cancellables)
        
        tableHeaderView.commentPublisher.sink(receiveValue: { [weak self] in
            guard let self = self else { return }
            if !self.commentTextView.isFirstResponder {
                self.commentTextView.becomeFirstResponder()
            }
        }).store(in: &cancellables)
        
        tableHeaderView.sharePublisher.sink(receiveValue: {
        }).store(in: &cancellables)
    }
    
    func bindCellSubscribe(type: CommentsCellType, cell: UITableViewCell, indexPath: IndexPath) {
        switch type {
        case let .comment(model):
            guard let cell = cell as? CommentsListCell else { return }
            cell.addReply.sink(receiveValue: { [unowned self] in
                self.cellIndex = indexPath
                self.setReplyStateTextView(author: model.author, commentId: model._id, isReply: true)
            }).store(in: &cell.cancellables)
            
            cell.openURL.sink(receiveValue: { [unowned self] url in
                self.viewModel.openURL(url: url, dismissSocialWebView: dismissSocialWebView)
            }).store(in: &cell.cancellables)
            
        case let .reply(_, commentId, commentAuthor):
            guard let cell = cell as? ReplyListCell else { return }
            cell.addReply.sink(receiveValue: { [unowned self] in
                self.cellIndex = indexPath
                self.setReplyStateTextView(author: commentAuthor, commentId: commentId, isReply: true)
            }).store(in: &cell.cancellables)
            
            cell.openURL.sink(receiveValue: { [unowned self] url in
                self.viewModel.openURL(url: url, dismissSocialWebView: dismissSocialWebView)
            }).store(in: &cell.cancellables)
        }
    }
    
    func setReplyStateTextView(author: Author, commentId: String, isReply: Bool) {
        if commentTextView.isFirstResponder {
            scrollToBotom()
        } else {
            commentTextView.becomeFirstResponder()
        }
        
        replyToModel = isReply ? .init(_id: author._id, username: author.title) : nil
        textViewPlaceHolderLabel.isHidden = true
        commentAuthor = author.title
        commentTextView.attributedText = ("@\(author.title) ").styleAll(userAttributes).attributedString
        commentTextView.savedTags.append(author.title)
        isReplyState = true
        sendCommentButton.isHidden = false
        self.commentId = commentId
    }
    
    func clearStateTextView() {
        commentTextView.text = ""
        resizeTextViewToFitText()
        textViewPlaceHolderLabel.isHidden = false
        sendCommentButton.isHidden = true
    }
    
    func updateTextViewText() {
       // self.commentTextView.attributedText = ""
    }
    
}

// MARK: - CommentsListVC: UITableViewDelegate
extension CommentsListVC: UITableViewDelegate {
    
    private func updateWithComments(with data: [CommentsCellType], animated: Bool = false, isScroll: Bool = false) {
        
        clearStateTextView()
        commentsTableView.removeActivityIndicator()
        commentsTableView.cr.endHeaderRefresh()
        
        DispatchQueue.main.async { [weak self] in
            var snapShot = NSDiffableDataSourceSnapshot<Int, CommentsCellType>()
            
            snapShot.appendSections([0])
            snapShot.appendItems(data)
            
            self?.commentsDataSource.apply(snapShot, animatingDifferences: animated)
            
            if isScroll {
                self?.getIndexWithNewItem(with: data)
                self?.scrollToBotom(isReplyPublished: true)
            }
        }
    }
    
    private func getIndexWithNewItem(with data: [CommentsCellType]) {
        data.enumerated().forEach({ index, value in
            switch value {
            case let .reply(reply, _, _):
                if reply._id == replyId {
                    cellIndex = .init(row: index, section: 0)
                }
            default: break
            }
        })
    }
    
    private func configureCommentsDataSource() -> UITableViewDiffableDataSource<Int, CommentsCellType> {
        
        let dataSource = UITableViewDiffableDataSource<Int, CommentsCellType>(
            tableView: commentsTableView) { [weak self] tableView, indexPath, type in
                switch type {
                case let .comment(model):
                    let cell = (tableView.dequeueReusableCell(withIdentifier: CommentsListCell.identifier, for: indexPath) as! CommentsListCell)
                        .config(with: model)
                    self?.bindCellSubscribe(type: type, cell: cell, indexPath: indexPath)
                    
                    return cell
                case let .reply(reply, _, _):
                    let cell = (tableView.dequeueReusableCell(withIdentifier: ReplyListCell.identifier, for: indexPath) as! ReplyListCell)
                        .config(with: reply)
                    self?.bindCellSubscribe(type: type, cell: cell, indexPath: indexPath)
                    
                    return cell
                }
        }
        
        return dataSource
    }
    
    private func configureUsersDataSource() -> UITableViewDiffableDataSource<Int, CommunityUser> {
        let dataSource = UITableViewDiffableDataSource<Int, CommunityUser>(
            tableView: companyUsersTable) { tableView, _, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: CommunityUserCell.identifier) as! CommunityUserCell
                cell.configure(with: model)
                return cell
        }
        
        return dataSource
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { // check when need load new post with pagination
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height + 100) > scrollView.contentSize.height ) && !viewModel.isPagination && viewModel.isReadyToPagination {
            viewModel.isPagination = true
            updateComments.send()
        }
    }
}

// MARK: - UITextViewDelegate
extension CommentsListVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.typingAttributes = plainAttributes.attributes

        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updateText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if updateText.isEmpty {
            sendCommentButton.isHidden = true
            resizeTextViewToFitText()
        } else {
            sendCommentButton.isHidden = isSendAvailable(text: updateText)
        }
        
        return updateText.count <= 150
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if isReplyState {
            isReplyState = textView.text.contains(commentAuthor) ? true : false
        }
        textViewPlaceHolderLabel.isHidden = textView.text.isEmpty ? false : true
        resizeTextViewToFitText()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let newPosition = textView.endOfDocument
        textView.selectedTextRange = commentTextView.textRange(from: newPosition, to: newPosition)
        commentTextView.getCursorPosition(text: textView.text)
    }
    
    private func resizeTextViewToFitText() {
        let size = CGSize(width: commentTextView.frame.width, height: .infinity)
        let expectedSize = commentTextView.sizeThatFits(size)
        self.heightTextView.constant = max(min(expectedSize.height, 94), 42)
        self.commentTextView.isScrollEnabled = expectedSize.height > 94
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func isSendAvailable(text: String) -> Bool {
        let result = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\\n{2,}", with: "\n", options: .regularExpression)
        return result.isEmpty
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.typingAttributes = plainAttributes.attributes
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == companyUsersTable {
            guard let model = usersDataSource.itemIdentifier(for: indexPath) else { return }
            //self.viewModel.addUser(model)
            self.applyUser(model)
            self.tableWrapView.isHidden = true
            self.resizeTextViewToFitText()
        }
    }
    
    func applyUser(_ model: CommunityUser) {
        commentTextView.applyTag(model)
    }
}

enum TaggingState {
    case notStarted
    case started
    case edit
    case applying
    case completed
}

extension String {
    func indexOf(_ input: String,
                 options: String.CompareOptions = .literal) -> String.Index? {
        return self.range(of: input, options: options)?.lowerBound
    }

    func lastIndexOf(_ input: String) -> String.Index? {
        return indexOf(input, options: .backwards)
    }
}

let USER_TAG = "@"
