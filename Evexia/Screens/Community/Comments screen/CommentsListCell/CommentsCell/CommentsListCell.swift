//
//  CommentsListCell.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 26.09.2021.
//

import UIKit
import Combine
import ActiveLabel
import Atributika

// MARK: - CommentsListCell
class CommentsListCell: UITableViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentTextLabel: AttributedLabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var сommentContainerView: UIView!
        
    // MARK: - Properties
    let addReply = PassthroughSubject<Void, Never>()
    let openURL = PassthroughSubject<URL, Never>()
    var cancellables = Set<AnyCancellable>()
    private var plainAttributes: Style {
        return Style
            .foregroundColor(.gray900, .normal)
            .font(UIFont(name: "NunitoSans-Regular", size: 16.0)!)
    }
    
    private var userAttributes: Style {
        return Style("tag")
            .foregroundColor(.orange, .normal)
            .foregroundColor(.orange, .highlighted)
            .font(UIFont(name: "NunitoSans-Bold", size: 16.0)!)
    }
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        addGesture()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    // MARK: - Methods
    @discardableResult
    func config(with model: CommentResponseModel) -> CommentsListCell {
        let avatarURL = URL(string: model.author.avatar?.fileUrl ?? "")
        avatarImageView.setImage(url: avatarURL)
        userNameLabel.text = model.author.title
        commentTextLabel.attributedText = model.content.style(tags: [self.userAttributes]).styleAll(self.plainAttributes)
        timeAgoLabel.text = (Double(model.createdAt / 1_000).timeAgoSince(type: .comment))
        
        return self
    }
}

// MARK: - Private Extension
private extension CommentsListCell {
    func setupUI() {
        setupAvatarImageView()
        setupUserNameLabel()
        setupPostTextLabel()
        setupTimeAgoLabel()
        setupReplyLabel()
        setupCommentContainerView()
        selectionStyle = . none
    }
    
    func setupAvatarImageView() {
        avatarImageView.layer.cornerRadius = 10
    }
    
    func setupUserNameLabel() {
        userNameLabel.font = UIFont(name: "NunitoSans-Semibold", size: 14.0)!
        userNameLabel.textColor = .gray900
    }
    
    func setupPostTextLabel() {
//        commentTextLabel.enabledTypes = [.url]
//        commentTextLabel.font = UIFont(name: "NunitoSans-Regular", size: 14.0)!
//        commentTextLabel.textColor = .gray900
//        commentTextLabel.URLColor = .systemBlue
//        commentTextLabel.handleURLTap { [weak self] url in
//            self?.openURL.send(url)
//        }
    }
    
    func setupTimeAgoLabel() {
        timeAgoLabel.font = UIFont(name: "NunitoSans-Regular", size: 14.0)!
        timeAgoLabel.textColor = .gray500
    }
    
    func setupReplyLabel() {
        replyLabel.font = UIFont(name: "NunitoSans-Bold", size: 14.0)!
        replyLabel.textColor = .gray700
    }
    
    func setupCommentContainerView() {
        сommentContainerView.backgroundColor = .gray200
        сommentContainerView.layer.cornerRadius = 16
    }
    
    func addGesture() {
        let tapReplyGesture = UITapGestureRecognizer(target: self, action: #selector(replyToComment))
        replyLabel.addGestureRecognizer(tapReplyGesture)
    }
    
    @objc
    func replyToComment(_ sender: UITapGestureRecognizer) {
        addReply.send()
    }
}
