//
//  CommunityCell.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import UIKit
import Combine
import AVKit
import Atributika

class PostCell: UITableViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var postTextView: AttributedLabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var sharesButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var additionalMenuButton: UIButton!
    @IBOutlet weak var socialListsStackView: UIStackView!
    @IBOutlet weak var likeToPostButton: UIButton!
    
    // MARK: - Properties
    let likesAndSharePublisher = PassthroughSubject<(LikesSharedStartVCType, String), Never>()
    let alertPublisher = PassthroughSubject<[AlertButton], Never>()
    let editPostPublisher = PassthroughSubject<Void, Never>()
    let deletePost = PassthroughSubject<String, Never>()
    let profilePublisher = PassthroughSubject<Void, Never>()
    let createCommentPublisher = PassthroughSubject<Void, Never>()
    let addRemoveLikePublisher = PassthroughSubject<String, Never>()
    let commentsListPublisher = PassthroughSubject<Void, Never>()
    let playVideoPublisher = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
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
            .foregroundColor(.gray900, .highlighted)
    }
    
    private var linkAttributes: Style {
        return Style
            .foregroundColor(.blue, .normal)
            .foregroundColor(.gray900, .highlighted)
            .font(UIFont(name: "NunitoSans-Semibold", size: 16.0)!)
    }
    
    private lazy var dataSource = configureDataSource()
    private var postId = ""
    private var likeCounter = 0
    private var commentCounter = 0
    private var tempVideoURL: String?
    private var tempAttachments: [Attachments] = []
    private var isLiked = false
    private var model: LocalPost?
    private var isDataUpdated: Bool = false
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        isDataUpdated = false

        likesButton.titleLabel?.text = nil
        commentsButton.titleLabel?.text = nil
        sharesButton.titleLabel?.text = nil
        avatarImageView.image = nil
    }
    
    // MARK: - Methods
    @discardableResult
    func config(with model: LocalPost) -> PostCell {
        self.model = model
        let url = URL(string: model.author.avatar?.fileUrl ?? "")
        avatarImageView.setImage(url: url)
        commentCounter = model.commentsCounter
        likeCounter = model.likesCounter
        titleLabel.text = model.author.title
        subTitleLabel.text = (Double(model.createdAt / 1_000).timeAgoSince(type: .post))
        postTextView.attributedText = model.content.style(tags: [userAttributes]).styleLinks(linkAttributes).styleAll(plainAttributes)
        setupPageController(
            with: model.video != nil
                ? model.attachments.count + 1
                : model.attachments.count
        )
        likesButton.setTitle(model.likesCounter >= 1 ? "\(model.likesCounter) likes" : "0 likes", for: .normal)
        commentsButton.setTitle(model.commentsCounter > 0 ? "\(model.commentsCounter) comments" : "0 comments", for: .normal)
        sharesButton.setTitle(model.shares.count >= 1 ? "\(model.shares.count) shares" : "0 shares", for: .normal)
        additionalMenuButton.isHidden = !checkIsMyPost(model: model)
        socialListsStackView.isHidden = checkIsHiddentSocialStack()
        collectionView.isHidden = model.attachments.isEmpty && model.video == nil
        postTextView.isHidden = model.content.isEmpty ? true : false
        likeToPostButton.setImage(model.isLiked ? UIImage(named: "ico_community_like_heart") : UIImage(named: "ico_community_heart"), for: .normal)
        isLiked = model.isLiked
        checkNeedReloadCollectionView(model: model)
        postId = model._id
        tempAttachments = model.attachments
        tempVideoURL = model.video?.fileUrl
        postTextView.onClick = { label, detection in
            switch detection.type {
            case .link(let url):
                UIApplication.shared.open(url)
            default:
                break
            }
        }
        self.layoutSubviews()
        return self
    }

    // MARK: - Action
    @IBAction func tapLike(_ sender: UIButton) {
        likeCounter += isLiked ? -1 : 1
        socialListsStackView.isHidden = checkIsHiddentSocialStack()
        
        likesButton.setTitle(likeCounter >= 1 ? "\(likeCounter) likes" : "0 likes", for: .normal)
        
        likeToPostButton.setImage(
            !isLiked
                ? UIImage(named: "ico_community_like_heart")
                : UIImage(named: "ico_community_heart"),
            for: .normal
        )
        
        isLiked.toggle()
        
        addRemoveLikePublisher.send(postId)
    }
    
    @IBAction func tapComment(_ sender: UIButton) {
        createCommentPublisher.send()
    }
    
    @IBAction func tapShares(_ sender: UIButton) {
    
    }
    
    @IBAction func tapPostEditButton(_ sender: UIButton) {
        let actions = [
            AlertButton(title: "Edit Post".localized(), style: .default) { [weak self] in
                self?.editPostPublisher.send()
            },
            AlertButton(title: "Delete Post".localized(), style: .destructive) { [weak self] in
                guard let self = self else { return }
                self.deletePost.send(self.postId)
            },
            AlertButton(title: "Cancel".localized(), style: .cancel) { }
        ]
        
        alertPublisher.send(actions)
    }
    
    @IBAction func openLikesList(_ sender: UIButton) {
        likesAndSharePublisher.send((.likes, postId))
    }
    
    @IBAction func openCommentsList(_ sender: UIButton) {
        commentsListPublisher.send()
    }
    
    @IBAction func openSharesList(_ sender: UIButton) {
        likesAndSharePublisher.send((.shares, postId))
    }
}

// MARK: - Private Extension
private extension PostCell {
    func setupUI() {
        setupCornerView()
        setupAvatarImageView()
        setupTitleLabel()
        setupSubTitleLabel()
        setupPostTextView()
        setupCollectionView()
        setupSocialFeedBack()
        setupSocialStackView()
    }
    
    func setupSocialStackView() {
        socialListsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        socialListsStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    func setupCornerView() {
        cornerView.layer.cornerRadius = 16
    }
    
    func setupAvatarImageView() {
        avatarImageView.layer.cornerRadius = 12
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Betterhelp"
        titleLabel.font = UIFont(name: "NunitoSans-Semibold", size: 16.0)!
        titleLabel.textColor = .gray900
    }
    
    func setupSubTitleLabel() {
        subTitleLabel.text = "3 hours ago"
        subTitleLabel.font = UIFont(name: "NunitoSans-Regular", size: 12.0)!
        subTitleLabel.textColor = .gray500
    }
    
    func setupPostTextView() {

    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.register(PostImageCell.nib, forCellWithReuseIdentifier: PostImageCell.identifier)
        collectionView.register(CollectionVideoCell.nib, forCellWithReuseIdentifier: CollectionVideoCell.identifier)
    }
    
    func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(UIScreen.main.bounds.width - 52),
            heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        section.visibleItemsInvalidationHandler = { [unowned self] visibleItems, point, env -> Void in
            let numberPage = Int(point.x / (env.container.contentSize.width - 20))
                                  
            visibleItems.forEach {
                let cell = self.collectionView.cellForItem(at: $0.indexPath)
                if let cell = cell as? CollectionVideoCell {
                    cell.pause()
                }
            }
            
            if let model = self.model, model.index != numberPage, self.getIsDataUpdated() {
                model.index = numberPage
            }
            self.pageControl.currentPage = numberPage
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
    
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
    
    func getIsDataUpdated() -> Bool {
        isDataUpdated
    }
    
    func setupSocialFeedBack() {
        with([likesButton, commentsButton, sharesButton]) {
            $0?.titleLabel?.font = UIFont(name: "NunitoSans-Semibold", size: 12.0)!
            $0?.titleLabel?.textColor = .gray700
        }
    }
    
    func setupPageController(with count: Int) {
        pageControl.isHidden = count < 2 ? true : false
        pageControl.numberOfPages = count
    }
    
    func checkIsHiddentSocialStack() -> Bool {
        likeCounter == 0 && commentCounter == 0
    }
    
    func checkNeedReloadCollectionView(model: LocalPost) {
        let isEditImageResult = Set(tempAttachments.flatMap { attach in
            model.attachments.map { attach.fileUrl == $0.fileUrl }
        }).count == 1
        if postId != model._id || isEditImageResult {
            reloadCollectionView(model: model)
        } else if let urlVideo = model.video?.fileUrl, urlVideo != tempVideoURL {
            reloadCollectionView(model: model)
        }
        
        if postId == model._id {
            isDataUpdated = true
        }
        
    }
    
    func checkIsMyPost(model: LocalPost) -> Bool {
        if "\(UserDefaults.userModel!.firstName) \(UserDefaults.userModel!.lastName)" == model.author.title {
            addGesture()
            return true
        }
        return false
    }
    
    func reloadCollectionView(model: LocalPost) {
        cofigureCellModel(model: model)
    }
    
    func addGesture() {
        let avatarGesture = UITapGestureRecognizer(target: self, action: #selector(navigationToProfile))
        avatarImageView.addGestureRecognizer(avatarGesture)
        avatarImageView.isUserInteractionEnabled = true
    }
        
    @objc
    func navigationToProfile(_ sender: UITapGestureRecognizer) {
        profilePublisher.send()
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension PostCell: UICollectionViewDelegate {
    
    func update(with data: [PostCellMediaType], animated: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            var snapShot = NSDiffableDataSourceSnapshot<Int, PostCellMediaType>()
            
            snapShot.appendSections([0])
            snapShot.appendItems(data)
            
            self?.dataSource.apply(snapShot, animatingDifferences: animated) { [weak self] in
                guard let self = self, let model = self.model else { return }
                self.collectionView.scrollToItem(at: .init(row: model.index, section: 0), at: .centeredHorizontally, animated: false)
            }
            self?.isDataUpdated = true
        }
    }
    
    private func configureDataSource() -> UICollectionViewDiffableDataSource<Int, PostCellMediaType> {
        
        let dataSource = UICollectionViewDiffableDataSource<Int, PostCellMediaType>(
            collectionView: collectionView) { [weak self] collectionView, indexPath, type in
            switch type {
            case let .image(imageUrl):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostImageCell.identifier, for: indexPath) as! PostImageCell
                cell.config(with: imageUrl)
               return cell
            case let .video(videoUrl, post):
                let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: CollectionVideoCell.identifier, for: indexPath) as! CollectionVideoCell)
                    .config(with: videoUrl, isHideButton: true, playPublisher: self?.playVideoPublisher, post: post)
                
                return cell
            }
            
        }
        
        return dataSource
    }
    
    private func cofigureCellModel(model: LocalPost) {
        
        var cells: [PostCellMediaType] = []
        if !model.attachments.isEmpty {
            cells.append(contentsOf: model.attachments.compactMap { .init(image: $0.fileUrl) })
        }
        
        if let videoURL = model.video?.fileUrl, let url = URL(string: videoURL) {
            cells.append(.video(url, model))
        }
        
        update(with: cells)
    }
}
