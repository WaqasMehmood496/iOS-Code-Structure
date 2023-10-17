//
//  CreatePostCell.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import UIKit
import Kingfisher
import Combine

// MARK: - CreatePostCell
class CreatePostCell: UITableViewCell, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var newPostView: UIView!
    @IBOutlet weak var newPostTitleLabel: UILabel!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var cornerView: UIView!
    
    // MARK: - Properties
    let createPostPublisher = PassthroughSubject<Void, Never>()
    let profilePublisher = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        addGesture()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    // MARK: - Methods
    func config() -> CreatePostCell {
        return self
    }
    
    @IBAction func tapToCreatePost(_ sender: UIButton) {
        createPostPublisher.send()
    }
}

// MARK: - Private Extension
private extension CreatePostCell {
    func setupUI() {
        setupAvatarImageView()
        setupNewPostView()
        cornerView.layer.cornerRadius = 16
    }
    
    func setupAvatarImageView() {
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.layer.cornerRadius = 10
        
        let urlString = UserDefaults.userModel?.avatar?.fileUrl ?? ""
        let url = URL(string: urlString)
        avatarImageView.setImage(url: url)
    }
    
    func setupNewPostView() {
        newPostView.layer.borderColor = UIColor.gray500.cgColor
        newPostView.layer.borderWidth = 1
        newPostView.layer.cornerRadius = 16
        newPostView.backgroundColor = .gray100
        
        let image = UIImage(named: "icon_community_clips")
        attachButton.setImage(image, for: .normal)
        
        newPostTitleLabel.text = "What’s on your mind?"
        
    }
    
    func addGesture() {
        let createPostGesture = UITapGestureRecognizer(target: self, action: #selector(navigationToCreatePost))
        newPostView.addGestureRecognizer(createPostGesture)
        
        let avatarGesture = UITapGestureRecognizer(target: self, action: #selector(navigationToProfile))
        avatarImageView.addGestureRecognizer(avatarGesture)
    }
    
    @objc
    func navigationToCreatePost(_ sender: UITapGestureRecognizer) {
        createPostPublisher.send()
    }
    
    @objc
    func navigationToProfile(_ sender: UITapGestureRecognizer) {
        profilePublisher.send()
    }
}
