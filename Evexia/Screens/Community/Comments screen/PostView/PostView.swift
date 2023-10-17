//
//  PostView.swift
//  Evexia
//
//  Created by admin on 27.09.2021.
//

import UIKit
import Combine
import Atributika

enum PostViewType {
    case openPost
    case commentsList
    case dailyGoalPost
    case createComment
}

// MARK: - PostView
class PostView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet var view: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postTextLabel: AttributedLabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var widthContentViewConstant: NSLayoutConstraint!
    @IBOutlet weak var likeToPostButton: UIButton!
    
    private var userAttributes: Style {
        return Style("tag")
            .foregroundColor(.orange, .normal)
            .foregroundColor(.orange, .highlighted)
            .font(UIFont(name: "NunitoSans-Bold", size: 16.0)!)
    }
    
    private var plainAttributes: Style {
        return Style
            .foregroundColor(.gray900, .normal)
            .foregroundColor(.gray900, .highlighted)
            .font(UIFont(name: "NunitoSans-Semibold", size: 16.0)!)
    }
    
    private var linkAttributes: Style {
        return Style
            .foregroundColor(.blue, .normal)
            .foregroundColor(.gray900, .highlighted)
            .font(UIFont(name: "NunitoSans-Semibold", size: 16.0)!)
    }
    
    // MARK: - Properties
    var playVideoPublisher = PassthroughSubject<Void, Never>()
    let likePublisher = PassthroughSubject<String, Never>()
    let commentPublisher = PassthroughSubject<Void, Never>()
    let sharePublisher = PassthroughSubject<Void, Never>()
    
    private var postId = ""
    private var dailyGoalPlaceholder = "Smashed it! Just beat my average daily goal of 5,000 steps!"
    private var isLiked = false
    
    private lazy var dataSource = configureDataSource()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetup()
    }
    
    // MARK: - Methods
    private func nibSetup() {
        backgroundColor = .clear
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.setupViews()
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    
    // MARK: - IBOutlets
    @IBAction func tapToLike() {
        likePublisher.send(postId)
        isLiked.toggle()
        likeToPostButton.setImage(
            isLiked
            ? UIImage(named: "ico_community_like_heart")
            : UIImage(named: "ico_community_heart"),
            for: .normal
        )
    }
    
    @IBAction func tapToAddComment() {
        commentPublisher.send()
    }
    
    @IBAction func tapToShare() {
        sharePublisher.send()
    }
}

// MARK: - Private Extension
private extension PostView {
    func setupViews() {
        setupAvatarImageView()
        setupPostTextLabel()
        setupUserNameLabel()
        setupCollectionView()
        
        postTextLabel.onClick = { label, detection in
            switch detection.type {
            case .link(let url):
                UIApplication.shared.open(url)
            default:
                break
            }
        }
    }
    
    func setupAvatarImageView() {
        avatarImageView.layer.cornerRadius = 12
    }
    
    func setupPostTextLabel() {
//        postTextLabel.paddingLeft = 16
//        postTextLabel.paddingRight = 16
//        postTextLabel.font = UIFont(name: "NunitoSans-Semibold", size: 16.0)!
//        postTextLabel.layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
//        postTextLabel.textColor = .gray900
        
        
    }
    
    func setupUserNameLabel() {
        userNameLabel.font = UIFont(name: "NunitoSans-Semibold", size: 16.0)!
        userNameLabel.textColor = .gray900
    }
    
    func setupCollectionView() {
        imageCollectionView.delegate = self
        imageCollectionView.backgroundColor = .clear
        imageCollectionView.showsHorizontalScrollIndicator = false
        imageCollectionView.bounces = false
        imageCollectionView.alwaysBounceHorizontal = false
        imageCollectionView.collectionViewLayout = createLayout()
        
        imageCollectionView.register(PostImageCell.nib, forCellWithReuseIdentifier: PostImageCell.identifier)
        imageCollectionView.register(CollectionVideoCell.nib, forCellWithReuseIdentifier: CollectionVideoCell.identifier)
    }
    
    func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(UIScreen.main.bounds.width - 20),
            heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension PostView: UICollectionViewDelegate {
    
    func cofigureCellModel(model: LocalPost, viewType: PostViewType) {
        postId = model._id
        isLiked = model.isLiked
        likeToPostButton.setImage(model.isLiked ? UIImage(named: "ico_community_like_heart") : UIImage(named: "ico_community_heart"), for: .normal)
        imageCollectionView.isHidden = model.attachments.isEmpty && model.video == nil
        postTextLabel.attributedText = viewType == .dailyGoalPost ? dailyGoalPlaceholder.styleAll(plainAttributes) : model.content.style(tags: [userAttributes]).styleLinks(linkAttributes).styleAll(plainAttributes)
        postTextLabel.numberOfLines = 0
        userNameLabel.text = model.author.title
        timeAgoLabel.text = (Double(model.createdAt / 1_000).timeAgoSince(type: .post))
        
        let urlString = model.author.avatar?.fileUrl ?? ""
        let url = URL(string: urlString)
        avatarImageView.setImage(url: url)
        
        var cells: [PostCellMediaType] = []
        
        if viewType == .commentsList {
            if !model.attachments.isEmpty {
                cells.append(.init(image: model.attachments.first?.fileUrl ?? ""))
            } else if let videoURL = model.video?.fileUrl, let url = URL(string: videoURL) {
                cells.append(.video(url, model))
            }
        } else {
            if !model.attachments.isEmpty {
                cells.append(contentsOf: model.attachments.compactMap { .init(image: $0.fileUrl) })
            }
            
            if let videoURL = model.video?.fileUrl, let url = URL(string: videoURL) {
                cells.append(.video(url, model))
            }
        }
        
        update(with: cells)
    }
    
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
            collectionView: imageCollectionView) { [weak self] collectionView, indexPath, type in
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
}
