//
//  СommunityVC.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import UIKit
import Combine
import CRRefresh
import Reachability

// MARK: CommunityVC
class CommunityVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noInternetImageView: UIImageView!
    
    // MARK: - Properties
    var viewModel: CommunityVMType!
    
    private let appear = PassthroughSubject<Void, Never>()
    private let deletePost = PassthroughSubject<String, Never>()
    private let createStaticPost = PassthroughSubject<String, Never>()
    private let dismissCreateAndUpdatePublisher = PassthroughSubject<String, Never>()
    private let addRemoveLikePublisher = PassthroughSubject<String, Never>()
    private let addCommentPublisher = PassthroughSubject<LocalPost, Never>()
    private let updatePosts = PassthroughSubject<Void, Never>()
    
    private var cancellables: [AnyCancellable] = []
    private let reachability = try! Reachability()
    private lazy var dataSource = configureDataSource()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(to: viewModel)
        view.showActivityIndicator()
        appear.send()
    }
}

// MARK: - Data Source
extension CommunityVC: UITableViewDelegate {
    
    func update(with data: [CommunityCellContent], animated: Bool = false) {
        tableView.cr.endHeaderRefresh()
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, CommunityCellContent>()
            
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            
            if #available(iOS 15.0, *) {
                self?.dataSource.applySnapshotUsingReloadData(snapshot)
            } else {
                self?.dataSource.apply(snapshot, animatingDifferences: animated)
            }
            self?.view.removeActivityIndicator()
        }
    }
    
    func updateSocial(with item: [CommunityCellContent], animated: Bool = false) {
        var snapShot = dataSource.snapshot()
        
        snapShot.reloadItems(item)
        
        dataSource.apply(snapShot, animatingDifferences: animated)
    }
    
    func configureDataSource() -> UITableViewDiffableDataSource<Int, CommunityCellContent> {
        let dataSource = UITableViewDiffableDataSource<Int, CommunityCellContent>(
            tableView: tableView) { [unowned self] tableView, indexPath, model in
                switch model {
                case .createPost:
                    let cell = (tableView.dequeueReusableCell(withIdentifier: CreatePostCell.identifier, for: indexPath) as! CreatePostCell)
                        .config()
                    self.createSubscribe(type: model, cell: cell)
                    cell.layoutIfNeeded()

                    return cell
                case .dailyGoal:
                    let cell = (tableView.dequeueReusableCell(withIdentifier: DailyGoalCell.identifier, for: indexPath) as! DailyGoalCell)
                        .config()
                    self.createSubscribe(type: model, cell: cell)
                    cell.layoutIfNeeded()

                    return cell
                case let .userPostWithDailyGoal(post):
                    let cell = (tableView.dequeueReusableCell(withIdentifier: PostWithDailyGoalCell.identifier, for: indexPath) as! PostWithDailyGoalCell)
                        .config(with: post)
                    self.createSubscribe(type: model, cell: cell)
                    cell.layoutIfNeeded()

                    return cell
                case let .userPost(post):
                    let cell = (tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as! PostCell)
                        .config(with: post)
                    self.createSubscribe(type: model, cell: cell)
                    cell.layoutIfNeeded()

                    return cell
                case let .company(post):
                    let cell = (tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as! PostCell)
                        .config(with: post)
                    self.createSubscribe(type: model, cell: cell)
                    cell.layoutIfNeeded()

                    return cell
                case let .partnerPost(post):
                    let cell = (tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as! PostCell)
                        .config(with: post)
                    self.createSubscribe(type: model, cell: cell)
                    cell.layoutIfNeeded()

                    return cell
                case let .benefitPost(post):
                    let cell = (tableView.dequeueReusableCell(withIdentifier: BenefitPostCell.identifier, for: indexPath) as! BenefitPostCell)
                        .config(with: post)
                    self.createSubscribe(type: model, cell: cell)
                    cell.layoutIfNeeded()
                    return cell
                }
        }
        
        return dataSource
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { // check when need load new post with pagination
        DispatchQueue.main.async {
            if ((scrollView.contentOffset.y + scrollView.frame.size.height + 100) > scrollView.contentSize.height ) && !self.viewModel.isPagination && self.viewModel.isReadyToPagination {
                self.viewModel.isPagination = true
                self.updatePosts.send()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) { // stop active video in vissible cell when cell didEndDisplaying
        
        if let cell = cell as? PostCell {
            cell.playVideoPublisher.send()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch model {
        case let .userPost(post):
            viewModel.navigateToCommentsList(post: post, addRemoveLikePublisher: self.addRemoveLikePublisher, addCommentPublisher: self.addCommentPublisher, viewType: .openPost)
        default: break
        }
    }
}

// MARK: - Private Extension
private extension CommunityVC {
    func setupUI() {
        setupNavigationBar()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.layer.masksToBounds = false
        tableView.layer.shadowColor = UIColor(hex: "#CBD5E0")?.cgColor
        tableView.layer.shadowOpacity = 0.5
        tableView.layer.shadowRadius = 5
        tableView.layer.shadowOffset = .zero

        tableView.cr.addHeadRefresh { [weak self] in
            self?.appear.send()
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        checkInternetState()
        registerCell()
    }
    
    func checkInternetState() {
        // connected observer
        self.reachability.whenReachable = { [weak self] _ in
            guard let self = self else { return }
            if self.tableView.cr.header?.state == .refreshing || self.viewModel.models.isEmpty {
                self.noInternetImageView.isHidden = true
                self.appear.send()
                self.view.showActivityIndicator()
            }
        }
        
        // start reachability observer
        do {
            try self.reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func setupNavigationBar() {
        navigationItem.title = "My Day Wellness Community".localized()
        self.navigationController?.navigationBar.backgroundColor = .gray100
    }
    
    func registerCell() {
        tableView.register(PostCell.nib, forCellReuseIdentifier: PostCell.identifier)
        tableView.register(DailyGoalCell.nib, forCellReuseIdentifier: DailyGoalCell.identifier)
        tableView.register(CreatePostCell.nib, forCellReuseIdentifier: CreatePostCell.identifier)
        tableView.register(PostWithDailyGoalCell.nib, forCellReuseIdentifier: PostWithDailyGoalCell.identifier)
        tableView.register(BenefitPostCell.nib, forCellReuseIdentifier: BenefitPostCell.identifier)
        tableView.register(EmptyFooterView.self, forHeaderFooterViewReuseIdentifier: EmptyFooterView.identifier)
    }
    
    // MARK: - Bind and render
    func bind(to viewModel: CommunityVMType) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        let input = CommunityVMInput(
            appear: appear.eraseToAnyPublisher(),
            updatePosts: updatePosts.eraseToAnyPublisher(),
            deletePost: deletePost.eraseToAnyPublisher(),
            createPost: createStaticPost.eraseToAnyPublisher(),
            dismissCreateAndUpdatePublisher: dismissCreateAndUpdatePublisher.eraseToAnyPublisher(),
            addRemoveLikePublisher: addRemoveLikePublisher.eraseToAnyPublisher(),
            addCommentPublisher: addCommentPublisher.eraseToAnyPublisher()
        )
        let output = viewModel.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }.store(in: &cancellables)
    }
    
    func render(_ state: CommunityVCState) {
        switch state {
        case let .somePage(model):
            update(with: model)
            viewModel.isReadyToPagination = true
        case let .lastPage(model):
            viewModel.isReadyToPagination = false
            update(with: model)
        case let .failure(error):
            if error == .init(errorCode: .networkConnectionError) && viewModel.models.isEmpty {
                view.removeActivityIndicator()
                noInternetImageView.isHidden = false
            }
            modalAlert(modalStyle: error.errorCode, completion: { })
        case .creatStaticPost:
            appear.send()
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.setContentOffset(.zero, animated: true)
            }
            
        case let .deletePost(model):
            update(with: model)
        case let .addSocialAction(model, type):
            if type == .comment {
                updateSocial(with: model)
            }
        default:
            break
        }
    }
    
    // MARK: - Create Subscribe
    func createSubscribe(type: CommunityCellContent, cell: UITableViewCell) {
        switch type {
        case let .userPost(post), let .company(post), let .partnerPost(post):
            guard let cell = cell as? PostCell else { return }
            
            cell.alertPublisher.sink(receiveValue: { [weak self] alertButtons in
                self?.showAllert(alertStyle: .actionSheet, actions: alertButtons)
            }).store(in: &cell.cancellables)
            
            cell.likesAndSharePublisher.sink(receiveValue: { [weak self] type, postId in
                self?.viewModel.presentLikesSharedVC(type: type, postId: postId)
            }).store(in: &cell.cancellables)
            
            cell.editPostPublisher.sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                
                self.viewModel.presentCreateEditVC(state: .edit, post: post, dismissPublisher: self.dismissCreateAndUpdatePublisher)
            }).store(in: &cell.cancellables)
            
            cell.deletePost.sink(receiveValue: { [weak self] postId in
                self?.modalAlert(modalStyle: ModalAlertViewStyles.deletePost, completion: {
                    self?.deletePost.send(postId)
                }, cancel: { })
            }).store(in: &cell.cancellables)
            
            cell.profilePublisher.sink { [weak self] _ in
                self?.viewModel.navigationToProfile()
            }.store(in: &cell.cancellables)
            
            cell.addRemoveLikePublisher.sink { [weak self] id in
                UIView.setAnimationsEnabled(false)
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
                self?.addRemoveLikePublisher.send(id)
                Vibration.selection.vibrate()
            }.store(in: &cell.cancellables)
            
            cell.createCommentPublisher.sink { [weak self] in
                guard let self = self else { return }
                self.viewModel.navigationToCreateComment(post: post, addCommentPublisher: self.addCommentPublisher, viewType: .createComment)
            }.store(in: &cell.cancellables)
            
            cell.commentsListPublisher.sink { [weak self] in
                guard let self = self else { return }
                self.viewModel.navigateToCommentsList(post: post, addRemoveLikePublisher: self.addRemoveLikePublisher, addCommentPublisher: self.addCommentPublisher, viewType: .commentsList)
            }.store(in: &cell.cancellables)
            
        case .createPost:
            guard let cell = cell as? CreatePostCell else { return }
            
            cell.createPostPublisher.sink { [weak self] _ in
                guard let self = self else { return }
                
                self.viewModel.presentCreateEditVC(state: .create, post: nil, dismissPublisher: self.dismissCreateAndUpdatePublisher)
            }.store(in: &cell.cancellables)
            
            cell.profilePublisher.sink { [weak self] _ in
                self?.viewModel.navigationToProfile()
            }.store(in: &cell.cancellables)
            
        case let .userPostWithDailyGoal(post):
            guard let cell = cell as? PostWithDailyGoalCell else { return }
            
            cell.likesAndSharePublisher.sink(receiveValue: { [weak self] type, postId in
                self?.viewModel.presentLikesSharedVC(type: type, postId: postId)
            }).store(in: &cell.cancellables)
            
            cell.deletePost.sink(receiveValue: { [weak self] postId in
                self?.modalAlert(modalStyle: ModalAlertViewStyles.deletePost, completion: {
                    self?.deletePost.send(postId)
                }, cancel: { })
            }).store(in: &cell.cancellables)
            
            cell.alertPublisher.sink(receiveValue: { [weak self] alertButtons in
                self?.showAllert(alertStyle: .actionSheet, actions: alertButtons)
            }).store(in: &cell.cancellables)
            
            cell.profilePublisher.sink { [weak self] _ in
                self?.viewModel.navigationToProfile()
            }.store(in: &cell.cancellables)
            
            cell.addRemoveLikePublisher.sink { [weak self] id in
                self?.addRemoveLikePublisher.send(id)
            }.store(in: &cell.cancellables)
            
            cell.createCommentPublisher.sink { [weak self] in
                guard let self = self else { return }
                self.viewModel.navigationToCreateComment(post: post, addCommentPublisher: self.addCommentPublisher, viewType: .dailyGoalPost)
            }.store(in: &cell.cancellables)
            
            cell.commentsListPublisher.sink { [weak self] in
                guard let self = self else { return }
                self.viewModel.navigateToCommentsList(post: post, addRemoveLikePublisher: self.addRemoveLikePublisher, addCommentPublisher: self.addCommentPublisher, viewType: .dailyGoalPost)
            }.store(in: &cell.cancellables)
            
        case .dailyGoal:
            guard let cell = cell as? DailyGoalCell else { return }
            
            cell.publishDailyGoalPublisher.sink(receiveValue: { [weak self] steps in
                self?.createStaticPost.send(steps)
            }).store(in: &cell.cancellables)
            
            cell.removeDailyGoalPublisher.sink(receiveValue: { [weak self] in
                self?.appear.send()
            }).store(in: &cell.cancellables)
            
        default: break
        }
    }
}

// MARK: Header & Footer
extension CommunityVC {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = EmptyFooterView()
        header.backgroundView?.backgroundColor = .clear
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = EmptyFooterView()
        footerView.backgroundView?.backgroundColor = .clear
        return footerView
    }
}
