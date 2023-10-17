//
//  CreateCommentVC.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 20.09.2021.
//

import UIKit
import Combine
import Atributika

// MARK: - CreateCommentVC
class CreateCommentVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var postTextLabel: AttributedLabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var commentTextView: TaggingTextView!
    @IBOutlet weak var contentViewTextView: UIView!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightTextView: NSLayoutConstraint!
    @IBOutlet weak var textViewPlaceHolderLabel: UILabel!
    @IBOutlet weak var companyUsersTable: UITableView!
    @IBOutlet weak var tableWrapView: UIView!
    @IBOutlet weak var usersTableHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    var viewModel: CreateCommentVMType!
    
    private let playVideoPublisher = PassthroughSubject<Void, Never>()
    private let appear = PassthroughSubject<Void, Never>()
    private let createCommentPublisher = PassthroughSubject<(String, [String]), Never>()

    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = configureDataSource()
    private var isScrollEnable = false
    private var dailyGoalPlaceholder = "Smashed it! Just beat my average daily goal of 5,000 steps!"
    private lazy var usersDataSource = configureUsersDataSource()
    
    private var userAttributes: Style {
        return Style("tag")
            .foregroundColor(.orange, .normal)
            .foregroundColor(.orange, .highlighted)
            .font(UIFont(name: "NunitoSans-Bold", size: 16.0)!)
    }
    
    private var plainAttributes: Style {
        return Style
            .foregroundColor(.gray900, .normal)
            .font(UIFont(name: "NunitoSans-Regular", size: 16.0)!)
        
    }
    
    private var linkAttributes: Style {
        return Style
            .foregroundColor(.blue, .normal)
            .foregroundColor(.gray900, .highlighted)
            .font(UIFont(name: "NunitoSans-Semibold", size: 16.0)!)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(to: viewModel)
        appear.send()
        handleHeightKeyboard()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playVideoPublisher.send()
    }
    
    // MARK: - Action
    @IBAction func closeVC() {
        if !commentTextView.text.isEmpty {
            modalAlert(modalStyle: ModalAlertViewStyles.notChangedEditPost, completion: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }, cancel: { })
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func createComment() {
        let text = commentTextView.getTaggedText()
        print(commentTextView.savedTags)
        createCommentPublisher.send((text, commentTextView.savedTags))
    }
}

// MARK: Bind & Render
extension CreateCommentVC {
    
    func bind(to viewModel: CreateCommentVMType) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        let input = CreateCommentVMInput(appear: appear.eraseToAnyPublisher(), createComment: createCommentPublisher.eraseToAnyPublisher())
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
    
    func render(_ state: CreateCommentVCState) {
        switch state {
        case let .idle(post):
            cofigureCellModel(model: post)
            commentTextView.becomeFirstResponder()
        case .createComment(_):
            commentTextView.resignFirstResponder()
            dismiss(animated: true, completion: nil)
        case let .failure(error):
            modalAlert(modalStyle: error.errorCode)
        }
    }
}

// MARK: - Private Extension
private extension CreateCommentVC {
    func setupUI() {
        setupContainerView()
        setupAvatarImageView()
        setupUserNameLabel()
        setupCollectionView()
        setupPostTextView()
        sendCommentButton.isHidden = true
    }
    
    func setupContainerView() {
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setupAvatarImageView() {
        avatarImageView.layer.cornerRadius = 12
    }
    
    func setupUserNameLabel() {
        userNameLabel.font = UIFont(name: "NunitoSans-Semibold", size: 16.0)!
        userNameLabel.textColor = .gray900
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
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.register(PostImageCell.nib, forCellWithReuseIdentifier: PostImageCell.identifier)
        collectionView.register(CollectionVideoCell.nib, forCellWithReuseIdentifier: CollectionVideoCell.identifier)
        
        companyUsersTable.delegate = self
        companyUsersTable.rowHeight = 68
        companyUsersTable.register(CommunityUserCell.nib, forCellReuseIdentifier: CommunityUserCell.identifier)
        companyUsersTable.separatorStyle = .none
    }
    
    func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(UIScreen.main.bounds.width - 32),
            heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
    
    func handleHeightKeyboard() {
        Publishers.keyboardHeightPublisher
            .sink(receiveValue: { [weak self] height, duration in
                guard let self = self else { return }
                self.view.layoutIfNeeded()
                self.textViewBottomConstraint.constant = height
                UIView.animate(withDuration: duration) {
                    if self.scrollView.contentInset.bottom < height {
                        let bottomInset = height + self.contentViewTextView.bounds.height - self.view.safeAreaInsets.bottom
                        self.scrollView.contentOffset.y += bottomInset
                        self.scrollView.contentInset.bottom = bottomInset
                        self.scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
                    }
                    self.view.layoutIfNeeded()
                }
                
            }).store(in: &cancellables)
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
    
}

// MARK: - UICollectionViewDelegate & DataSource
extension CreateCommentVC: UICollectionViewDelegate {
    
    private func update(with data: [PostCellMediaType], animated: Bool = false) {
        DispatchQueue.main.async {
            var snapShot = NSDiffableDataSourceSnapshot<Int, PostCellMediaType>()
            
            snapShot.appendSections([0])
            snapShot.appendItems(data)
            
            self.dataSource.apply(snapShot, animatingDifferences: animated)
        }
    }
    
    private func configureDataSource() -> UICollectionViewDiffableDataSource<Int, PostCellMediaType> {
        
        let dataSource = UICollectionViewDiffableDataSource<Int, PostCellMediaType>(
            collectionView: collectionView) { [weak self] collectionView, indexPath, type in
                switch type {
                case let .image(imageUrl):
                    let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: PostImageCell.identifier, for: indexPath) as! PostImageCell)
                    cell.config(with: imageUrl)
                    return cell
                case let .video(videoUrl, model):
                    let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: CollectionVideoCell.identifier, for: indexPath) as! CollectionVideoCell)
                        .config(with: videoUrl, isHideButton: true, playPublisher: self?.playVideoPublisher, post: model)
                    
                    return cell
                }
        }
        
        return dataSource
    }
    
    private func cofigureCellModel(model: LocalPost) {
        collectionView.isHidden = model.attachments.isEmpty && model.video == nil
        postTextLabel.attributedText = viewModel.viewType == .dailyGoalPost ? dailyGoalPlaceholder.styleAll(plainAttributes) : model.content.style(tags: [userAttributes]).styleLinks(linkAttributes).styleAll(plainAttributes)
        
        postTextLabel.onClick = { label, detection in
            switch detection.type {
            case .link(let url):
                UIApplication.shared.open(url)
            default:
                break
            }
        }
        userNameLabel.text = model.author.title
        let urlString = model.author.avatar?.fileUrl ?? ""
        let url = URL(string: urlString)
        avatarImageView.setImage(url: url)
        subTitleLabel.text = (Double(model.createdAt / 1_000).timeAgoSince(type: .post))
        
        var cells: [PostCellMediaType] = []
        
        if !model.attachments.isEmpty {
            cells.append(.init(image: model.attachments.first?.fileUrl ?? ""))
        } else if let videoURL = model.video?.fileUrl, let url = URL(string: videoURL) {
            cells.append(.video(url, model))
        }
        
        update(with: cells)
    }
}

// MARK: - UITextViewDelegate
extension CreateCommentVC: UITextViewDelegate {
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
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        commentTextView.getCursorPosition(text: textView.text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textViewPlaceHolderLabel.isHidden = textView.text.isEmpty ? false : true
        resizeTextViewToFitText()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.typingAttributes = plainAttributes.attributes
        return true
    }
    
    private func resizeTextViewToFitText() {
        let size = CGSize(width: commentTextView.frame.width, height: .infinity)
        let expectedSize = commentTextView.sizeThatFits(size)
        self.heightTextView.constant = max(min(expectedSize.height, 94), 42)
        self.commentTextView.isScrollEnabled = expectedSize.height > 94
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func isSendAvailable(text: String) -> Bool {
        let result = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\\n{2,}", with: "\n", options: .regularExpression)
        
        return result.isEmpty
    }
}

extension CreateCommentVC: UITableViewDelegate {
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
