//
//  CreatePostVC.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 07.09.2021.
//

import UIKit
import Combine
import Kingfisher
import Atributika

// MARK: - CreateEditPostVC
class CreateEditPostVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postTextView: TaggingTextView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var navRightButton: UIButton!
    @IBOutlet weak var attachImage: UIButton!
    @IBOutlet weak var textViewPlaceHolderLabel: UILabel!
    @IBOutlet weak var countSymbolsLabel: UILabel!
    @IBOutlet weak var lengthLimitLabel: UILabel!
    @IBOutlet weak var companyUsersTable: UITableView!
    @IBOutlet weak var tableWrapView: UIView!
    @IBOutlet weak var usersTableHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    var viewModel: CreateEditPostVMType!
    private let appear = PassthroughSubject<Void, Never>()
    private let addVideo = PassthroughSubject<(URL, [UIImage]), Never>()
    private let addImage = PassthroughSubject<[UIImage], Never>()
    private let removeImage = PassthroughSubject<[UIImage], Never>()
    private let removeVideo = PassthroughSubject<Void, Never>()
    private let createPost = PassthroughSubject<(CreatePostRequestModel, [String]), Never>()
    private let updatePost = PassthroughSubject<(CreatePostRequestModel, String, [String]), Never>()
    private let uploadImage = PassthroughSubject<[UIImage], Never>()
    private let uploadVideo = PassthroughSubject<Void, Never>()
    private let changeVideoIndex = PassthroughSubject<Int, Never>()
    private let playVideoPublisher = PassthroughSubject<Void, Never>()
    private let prepareModelBeforeUpload = PassthroughSubject<([Attachments], String, Attachments?), Never>()
    private let postLenghtLimit = 1_000
    private lazy var usersDataSource = configureUsersDataSource()
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
    
    var tempAttachments: [Attachments]?
    
    private lazy var dataSource = configuredataSourceCreatePost()
    private let picker = ImagePicker()
    private var images: [UIImage] = [] {
        didSet {
            checkSendState()
        }
    }
    
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(to: viewModel)
        appear.send()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playVideoPublisher.send()
    }
    
    // MARK: - Action
    @IBAction func tapToCloseVc(_ sender: UIButton) {
        checkContentInPost()
    }
    
    @IBAction func tapToCreatePost(_ sender: UIButton) {
        images.count >= 1 || viewModel.index != nil
            ? uploadAttachments(isLastRequest: false)
            : createOrUpdatePost(videoAttachment: nil)
    }
    
    @IBAction func tapToAddPicture(_ sender: UIButton) {
        if images.count != 5 {
            if viewModel.index != nil {
                picker.mediaTypes = ["public.image"]
            } else {
                picker.mediaTypes = ["public.image", "public.movie"]
            }
            
            showActionSheet(picker: picker)
        }
    }
}

// MARK: - Bind & Render
extension CreateEditPostVC {
    func bind(to viewModel: CreateEditPostVMType) {
        cancellable.forEach { $0.cancel() }
        cancellable.removeAll()
        
        let input = CreateEditPostVMInput(
            appear: appear.eraseToAnyPublisher(),
            addImage: addImage.eraseToAnyPublisher(),
            addVideo: addVideo.eraseToAnyPublisher(),
            removeImage: removeImage.eraseToAnyPublisher(),
            removeVideo: removeVideo.eraseToAnyPublisher(),
            createPost: createPost.eraseToAnyPublisher(),
            uploadImage: uploadImage.eraseToAnyPublisher(),
            updatePost: updatePost.eraseToAnyPublisher(),
            uploadVideo: uploadVideo.eraseToAnyPublisher(),
            changeVideoIndex: changeVideoIndex.eraseToAnyPublisher(),
            prepareModelBeforeUpload: prepareModelBeforeUpload.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.sink { [weak self] state in
            self?.render(state)
        }.store(in: &cancellable)
        
        self.viewModel.communityUsers
            .sink(receiveValue: { [weak self] users in
                self?.updateUsersTable(with: users)
            }).store(in: &cancellable)

        postTextView.searchText
            .sink(receiveValue: { [weak self] search in
                switch search {
                case let .search(text):
                    self?.viewModel.searchUsers(text)
                case .stop:
                    self?.viewModel.communityUsers.send([])
                }
            }).store(in: &cancellable)
    }
    
    private func updateUsersTable(with users: [CommunityUser]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableWrapView.isHidden = (users.isEmpty && self.postTextView.text.isEmpty)
            var snapShot = NSDiffableDataSourceSnapshot<Int, CommunityUser>()
            snapShot.appendSections([0])
            snapShot.appendItems(users)
            self.usersDataSource.apply(snapShot, animatingDifferences: false)
            
            if users.count > 3 {
                self.usersTableHeight.constant = 3 * 68.0
                self.companyUsersTable.isScrollEnabled = true
            } else {
                self.usersTableHeight.constant = Double(users.count) * 68.0
                self.companyUsersTable.isScrollEnabled = false
            }
        }
    }
    
    func render(_ state: CreateEditPostVCState) {
        switch state {
        case let .idle(post):
            if let post = post {
                configureVC(with: post)
                downloadImage(with: post.attachments)
            }
            postTextView.becomeFirstResponder()
        case let .successImages(attachments):
            tempAttachments = attachments
            uploadAttachments(isLastRequest: viewModel.index != nil ? false : true)
        case let .successVideo(attachment):
            uploadAttachments(isLastRequest: true, videoAttachment: attachment)
        case let .addImage(model):
            update(with: model)
        case let .addVideo(model):
            update(with: model)
        case let .removeImage(model):
            update(with: model)
        case .removeVideo:
            update(with: images.compactMap { .init(image: $0) })
            checkSendState()
        case let .createPost(post):
            viewModel.dismissPublisher.send(post._id)
            dismiss(animated: true, completion: nil)
        case let .editPost(post):
            viewModel.dismissPublisher.send(post._id)
            dismiss(animated: true, completion: nil)
        case .changeVideoIndex:
            checkSendState()
        case let .readyToUploadPost(model):
            uploadPost(model: model)
        default:
            break
        }
    }
    
    func createOrUpdatePost(videoAttachment: Attachments?) {
        let imageAttachments = tempAttachments == nil ? [] : tempAttachments!
        let textContent = postTextView.getTaggedText()
        let videoAttachment = videoAttachment != nil ? videoAttachment! : nil
        prepareModelBeforeUpload.send((imageAttachments, textContent, videoAttachment))
    }
    
    func uploadPost(model: CreatePostRequestModel) {
        if let post = viewModel.post {
            updatePost.send((model, post._id, postTextView.savedTags))
        } else {
            createPost.send((model, postTextView.savedTags))
        }
        tempAttachments = nil
    }
}

// MARK: - UICollectionViewCompositionalLayout
extension CreateEditPostVC {
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(view.bounds.width - 20),
            heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
}

// MARK: - UICollectionViewDelegate & dataSourceCreatePost with createPost
extension CreateEditPostVC: UICollectionViewDelegate {
    
    func update(with attachments: [CellMediaType], animated: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, CellMediaType>()
            
            snapshot.appendSections([0])
            snapshot.appendItems(attachments)
            
            self?.dataSource.apply(snapshot, animatingDifferences: animated)
        }
    }
    
    private func configuredataSourceCreatePost() -> UICollectionViewDiffableDataSource<Int, CellMediaType> {
        let dataSourceCreatePost = UICollectionViewDiffableDataSource<Int, CellMediaType>(
            collectionView: imageCollectionView) { [unowned self] collectionView, indexPath, type in
            switch type {
            case let .image(image):
                let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: CreateEditPostCell.identifier, for: indexPath) as! CreateEditPostCell)
                    .config(with: image, urlImage: nil)
                cell.deleteImagePublisher
                    .sink { [unowned self] _ in
                        self.images.remove(at: indexPath.item > images.count - 1 ? indexPath.item - 1 : indexPath.item)
                        if let index = viewModel.index { // check position video in collectionView is view isn;t nil
                            if index != 0, indexPath.item < index {
                                changeVideoIndex.send(index - 1)
                            }
                        }
                        self.removeImage.send(self.images)
                    }.store(in: &cell.cancellable)
                
                return cell
            case let .video(url):
                let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: CollectionVideoCell.identifier, for: indexPath) as! CollectionVideoCell)
                    .config(with: url, isHideButton: false, playPublisher: playVideoPublisher, post: viewModel.post)
                cell.deleteVideoPublisher
                    .sink { [weak self] _ in
                        self?.removeVideo.send()
                    }.store(in: &cell.cancellables)
                return cell
            }
            
        }
        return dataSourceCreatePost
    }
}

// MARK: - Private Extension
private extension CreateEditPostVC {
    func setupUI() {
        setupNavigationBar()
        setupImagePicker()
        setupContainerView()
        setupAvatarImageView()
        setupUserNameLabel()
        setupCollectionView()
        setupPostTextView()
        setupWrapView()
    }
    
    func setupWrapView() {
        tableWrapView.dropShadow(radius: 8, xOffset: 2, yOffset: 2, shadowOpacity: 0.4, shadowColor: .gray400)
        companyUsersTable.layer.cornerRadius = 8.0
        companyUsersTable.clipsToBounds = true
        tableWrapView.layer.cornerRadius = 8.0
    }
    
    func setupNavigationBar() {
        navTitleLabel.text = viewModel.startVCState == .create
            ? "Create Post".localized()
            : "Edit Post".localized()
        
        navRightButton.setTitle(
            viewModel.startVCState == .create
                ? "Post".localized()
                : "Edit".localized(),
            for: .normal
        )
        navRightButton.isUserInteractionEnabled = false
        navRightButton.alpha = 0.3
    }
    
    func setupImagePicker() {
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = ["public.image", "public.movie"]
    }
    
    func setupContainerView() {
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setupAvatarImageView() {
        avatarImageView.layer.cornerRadius = 12
        
        let urlString = UserDefaults.userModel?.avatar?.fileUrl ?? ""
        let url = URL(string: urlString)
        avatarImageView.setImage(url: url)
    }
    
    func setupUserNameLabel() {
        userNameLabel.font = UIFont(name: "NunitoSans-Semibold", size: 16.0)!
        userNameLabel.textColor = .gray900
        userNameLabel.text = "\(UserDefaults.userModel?.firstName ?? "") \(UserDefaults.userModel?.lastName ?? "")"
    }
    
    func setupPostTextView() {
        postTextView.delegate = self
        postTextView.textContainerInset = .zero
        postTextView.font = UIFont(name: "NunitoSans-Regular", size: 16.0)!
        postTextView.textColor = .gray900
    }
    
    func setupCollectionView() {
        imageCollectionView.delegate = self
        imageCollectionView.backgroundColor = .clear
        imageCollectionView.showsHorizontalScrollIndicator = false
        imageCollectionView.bounces = false
        imageCollectionView.isPagingEnabled = true
        imageCollectionView.collectionViewLayout = createLayout()
        
        imageCollectionView.register(CreateEditPostCell.nib, forCellWithReuseIdentifier: CreateEditPostCell.identifier)
        imageCollectionView.register(CollectionVideoCell.nib, forCellWithReuseIdentifier: CollectionVideoCell.identifier)
        
        companyUsersTable.delegate = self
        companyUsersTable.rowHeight = 68
        companyUsersTable.register(CommunityUserCell.nib, forCellReuseIdentifier: CommunityUserCell.identifier)
        companyUsersTable.separatorStyle = .none
    }
    
    func configureVC(with model: LocalPost) {
//        postTextView.text = model.content.isEmpty ? "" : model.content
//        postTextView.textColor = .gray900
        replaceTags(text: model.content.isEmpty ? "" : model.content)
        navRightButton.isUserInteractionEnabled = isSendAvailable(text: model.content)
        navRightButton.changeAlpha(isEnabled: isSendAvailable(text: postTextView.text))
        viewModel.index = model.video?.fileUrl == nil ? nil : model.attachments.count
        if let urlVideo = model.video?.fileUrl, let url = URL(string: urlVideo) {
            viewModel.urlVideo = url
        }
       
    }
    
    func replaceTags(text: String) {
        let pattern = "<tag>(.+?)</tag>"
        let matcher = text.match(pattern)
        var mutableStringA = NSMutableAttributedString(string: text, attributes: plainAttributes.attributes)
        var mutableString = mutableStringA.mutableString
        
        for i in matcher {
            let rangeOfStringToBeReplaced = mutableString.range(of: i[0])
            let attrString = NSMutableAttributedString(string: "@" + i[1], attributes: userAttributes.attributes)
            mutableStringA.replaceCharacters(in: rangeOfStringToBeReplaced, with: attrString)
            postTextView.savedTags.append(i[1])
        }
        
        print(mutableString)
        
        self.postTextView.attributedText = mutableStringA
    }

    func downloadImage(with attachments: [Attachments]) {
        let group = DispatchGroup()
        attachments.forEach { image in
            group.enter()
            guard let url = URL(string: image.fileUrl) else {
                return
            }
            let resource = ImageResource(downloadURL: url)

            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { [weak self] result in
                switch result {
                case .success(let value):
                    self?.images.append(value.image)
                    group.leave()
                case .failure(_):
                    group.leave()
                }
            }
        }
        group.notify(queue: .main, execute: { [weak self] in
            guard let self = self else { return }
            self.addImage.send(self.images)
        })
    }
    
    func uploadAttachments(isLastRequest: Bool, videoAttachment: Attachments? = nil) {
        // set activity indicator when start upload
        navRightButton.setTitle(" ", for: .normal)
        navRightButton.titleLabel?.showActivityIndicator()
        
        // start upload media
        if isLastRequest {
            createOrUpdatePost(videoAttachment: videoAttachment)
        } else if !images.isEmpty, tempAttachments == nil {
            uploadImage.send(images)
        } else if viewModel.index != nil {
            uploadVideo.send()
        }
    }
    
    func isSendAvailable(text: String) -> Bool {
        let result = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\\n{2,}", with: "\n", options: .regularExpression)
        
        return !result.isEmpty || !images.isEmpty || viewModel.index != nil
    }
    
    func checkContentInPost() {
        if !postTextView.text.isEmpty || !images.isEmpty {
            modalAlert(modalStyle: ModalAlertViewStyles.notChangedEditPost, completion: { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }, cancel: { })
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func checkSendState() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.attachImage.isEnabled = self?.images.count == 5 ? false : true
        }
       
        navRightButton.isUserInteractionEnabled = isSendAvailable(text: postTextView.text)
        navRightButton.changeAlpha(isEnabled: isSendAvailable(text: postTextView.text))
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

// MARK: UIImagePickerControllerDelegate
extension CreateEditPostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            images.append(image)
            addImage.send(images)
        } else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            changeVideoIndex.send(images.isEmpty ? 0 : images.count)
            addVideo.send((videoURL, images))
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            if self.viewModel.dataSource.count > 1 {
                let indexPath = IndexPath(item: self.viewModel.dataSource.count - 1, section: 0)
                self.imageCollectionView.isPagingEnabled = false
                self.imageCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.imageCollectionView.isPagingEnabled = true
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension CreateEditPostVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        textView.typingAttributes = plainAttributes.attributes

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updateText = currentText.replacingCharacters(in: stringRange, with: text)
        
        navRightButton.isUserInteractionEnabled = isSendAvailable(text: updateText)
        navRightButton.changeAlpha(isEnabled: isSendAvailable(text: updateText))
        
        return updateText.count <= self.postLenghtLimit
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let newPosition = textView.endOfDocument
        textView.selectedTextRange = postTextView.textRange(from: newPosition, to: newPosition)
        postTextView.getCursorPosition(text: textView.text)
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        countSymbolsLabel.text = "\(textView.text.count)"
        textViewPlaceHolderLabel.isHidden = textView.text.isEmpty ? false : true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        countSymbolsLabel.text = "\(textView.text.count)"
        textViewPlaceHolderLabel.isHidden = textView.text.isEmpty ? false : true
    }
}

// MARK: - CreateEditPostVC: UITableViewDelegate
extension CreateEditPostVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == companyUsersTable {
            guard let model = usersDataSource.itemIdentifier(for: indexPath) else { return }
            //self.viewModel.addUser(model)
            self.applyUser(model)
            self.tableWrapView.isHidden = true
        }
    }
    
    func applyUser(_ model: CommunityUser) {
        postTextView.applyTag(model)
    }
}

extension String {
    func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map { match in
            (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
}
