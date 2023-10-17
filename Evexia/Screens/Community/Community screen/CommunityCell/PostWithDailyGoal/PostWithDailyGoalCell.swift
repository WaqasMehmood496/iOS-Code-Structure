//
//  PostWithDailyGoalCell.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 06.09.2021.
//

import UIKit
import Combine

// MARK: - PostWithDailyGoalCell
class PostWithDailyGoalCell: UITableViewCell, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var dailyGoalView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avarageStepsTitleLabel: UILabel!
    @IBOutlet weak var userCountStepLabel: UILabel!
    @IBOutlet weak var averageDailyCountStepsTitle: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarTitleLabel: UILabel!
    @IBOutlet weak var avatarSubTitleLabel: UILabel!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var sharesButton: UIButton!
    @IBOutlet weak var additionalMenuButton: UIButton!
    @IBOutlet weak var socialListsStackView: UIStackView!
    @IBOutlet weak var likeToPostButton: UIButton!
    
    // MARK: - Properties
    let likesAndSharePublisher = PassthroughSubject<(LikesSharedStartVCType, String), Never>()
    let alertPublisher = PassthroughSubject<[AlertButton], Never>()
    let deletePost = PassthroughSubject<String, Never>()
    let profilePublisher = PassthroughSubject<Void, Never>()
    let addRemoveLikePublisher = PassthroughSubject<String, Never>()
    let createCommentPublisher = PassthroughSubject<Void, Never>()
    let commentsListPublisher = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
    private var postId = ""
    private var isLiked = false
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        likesButton.titleLabel?.text = nil
        commentsButton.titleLabel?.text = nil
        sharesButton.titleLabel?.text = nil
        
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    // MARK: - Methods
    @discardableResult
    func config(with model: LocalPost) -> PostWithDailyGoalCell {
        let url = URL(string: model.author.avatar?.fileUrl ?? "")
        avatarImageView.setImage(url: url)
        avatarTitleLabel.text = model.author.title
        avatarSubTitleLabel.text = (Double(model.createdAt / 1_000).timeAgoSince(type: .post))
        likesButton.setTitle(
            model.likesCounter >= 1 ? "\(model.likesCounter) likes" : "0 likes", for: .normal)
        commentsButton.setTitle(
            model.commentsCounter > 0 ? "\(model.commentsCounter) comments" : "0 comments", for: .normal)
        sharesButton.setTitle(
            model.shares.count >= 1 ? "\(model.shares.count) shares" : "0 shares", for: .normal)
        postId = model._id
        likeToPostButton.setImage(model.isLiked ? UIImage(named: "ico_community_like_heart") : UIImage(named: "ico_community_heart"), for: .normal)
        additionalMenuButton.isHidden = !checkIsMyPost(model: model)
        socialListsStackView.isHidden = model.likesCounter == 0
            && model.shares.isEmpty
            && model.commentsCounter == 0
        userCountStepLabel.textColor = .pink
        userCountStepLabel.text = model.content
        
        return self
    }
    
    // MARK: - Action
    @IBAction func tapLikeButton(_ sender: UIButton) {
        addRemoveLikePublisher.send(postId)
//        isLiked.toggle()
        likeToPostButton.setImage(
            isLiked
                ? UIImage(named: "ico_community_like_heart")
                : UIImage(named: "ico_community_heart"),
            for: .normal
        )
    }
    
    @IBAction func tapCommentButton(_ sender: UIButton) {
        createCommentPublisher.send()
    }
    
    @IBAction func tapShareButton(_ sender: UIButton) {
        
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
    
    @IBAction func tapPostEditButton() {
        let actions = [
            AlertButton(title: "Delete Post".localized(), style: .destructive) { [weak self] in
                guard let self = self else { return }
                self.deletePost.send(self.postId)
            },
            AlertButton(title: "Cancel".localized(), style: .cancel) { }
        ]
        alertPublisher.send(actions)
    }
}

// MARK: - Private Extension {
private extension PostWithDailyGoalCell {
    func setupUI() {
        setupCornerView()
        setupDailyGoalView()
        setupPostView()
    }
    
    func setupCornerView() {
        cornerView.layer.cornerRadius = 16
    }
    
    func setupDailyGoalView() {
        setupBackGroundView()
        setupTitleLabel()
        setupAvarageStepsTitleLabel()
        setupAverageDailyCountStepsTitle()
    }
    
    func setupPostView() {
        setupAvatarImageView()
        setupAvaterTitleLabel()
        setupSubTitleLabel()
        setupSocialFeedBack()
    }
    
    func setupBackGroundView() {
        dailyGoalView.backgroundColor = UIColor(hex: "#F7FAFC")
        dailyGoalView.layer.borderWidth = 1
        dailyGoalView.layer.borderColor = UIColor(hex: "E2E8F0")?.cgColor
        dailyGoalView.layer.cornerRadius = 16
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Smashed it! Just beat my average daily goal of 5,000 steps!".localized()
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .eatDark
    }
    
    func setupAvarageStepsTitleLabel() {
        avarageStepsTitleLabel.text = "Avarege steps / day"
        avarageStepsTitleLabel.textAlignment = .center
        avarageStepsTitleLabel.textColor = .gray500
    }
    
    func setupAverageDailyCountStepsTitle() {
        averageDailyCountStepsTitle.text = " / 5000"
        averageDailyCountStepsTitle.textColor = .gray500
    }
    
    func setupAvatarImageView() {
        avatarImageView.layer.cornerRadius = 12
        avatarImageView.isUserInteractionEnabled = true
    }
    
    func setupAvaterTitleLabel() {
        avatarTitleLabel.text = "Betterhelp"
        avatarTitleLabel.font = UIFont(name: "NunitoSans-Semibold", size: 16.0)!
        avatarTitleLabel.textColor = .gray900
    }
    
    func setupSubTitleLabel() {
        avatarSubTitleLabel.text = "3 hours ago"
        avatarSubTitleLabel.font = UIFont(name: "NunitoSans-Regular", size: 12.0)!
        avatarSubTitleLabel.textColor = .gray500
    }
    
    func setupSocialFeedBack() {
        with([likesButton, commentsButton, sharesButton]) {
            $0?.titleLabel?.font = UIFont(name: "NunitoSans-Semibold", size: 12.0)!
            $0?.titleLabel?.textColor = .gray700
        }
    }
    
    func addGesture() {
        let avatarGesture = UITapGestureRecognizer(target: self, action: #selector(navigationToProfile))
        avatarImageView.addGestureRecognizer(avatarGesture)
    }
    
    @objc
    func navigationToProfile(_ sender: UITapGestureRecognizer) {
        profilePublisher.send()
    }
    
    func checkIsMyPost(model: LocalPost) -> Bool {
        if "\(UserDefaults.userModel!.firstName) \(UserDefaults.userModel!.lastName)" == model.author.title {
            addGesture()
            return true
        }
        return false
    }
}
