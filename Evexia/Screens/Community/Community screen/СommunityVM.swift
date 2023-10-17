//
//  СommunityVM.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import Combine
import Foundation

// MARK: - SocialAction
enum SocialAction {
    case like
    case comment
    case share
}

// MARK: - СommunityVM
class СommunityVM: CommunityVMType {
    
    // MARK: - Properties
    var isPagination: Bool = false
    var isReadyToPagination: Bool = false
    var models: [LocalPost] = []
    
    private let repository: СommunityRepositoryProtocol
    private let router: CommunityNavigation
    private var cancellables: [AnyCancellable] = []
    
    private var tempDataSource: [CommunityCellContent] = []
    private var postId: String = ""
    
    // MARK: - Init
    init(repository: СommunityRepositoryProtocol, router: CommunityNavigation) {
        self.repository = repository
        self.router = router
    }
    
    // MARK: - Bind
    func transform(input: CommunityVMInput) -> CommunityVMOtput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    
        let idle = input.appear
            .flatMap { [unowned self] _ -> AnyPublisher<Result<Community, ServerError>, Never> in
                return self.repository.getPosts(model: createPaginationModel(isPaging: false))
            }
            .receive(on: DispatchQueue.main)
            .map { [unowned self] result -> CommunityVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(model):
                    return self.reloadDataSource(model: model.data)
                }
            }.eraseToAnyPublisher()
        
        let updateWithPadding = input.updatePosts
            .flatMap { [unowned self] _ -> AnyPublisher<Result<Community, ServerError>, Never> in
                return self.repository.getPosts(model: createPaginationModel(isPaging: true))
            }
            .receive(on: DispatchQueue.main)
            .map { [unowned self] result -> CommunityVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(model):
                    return self.updateDataSourcewithPading(model: model.data)
                }
            }.eraseToAnyPublisher()
        
        let createStaticPost = input.createPost
            .flatMap({ [unowned self] steps -> AnyPublisher<Result<Post, ServerError>, Never> in
                return self.repository.createStaticPost(steps: steps)
            })
            .map({ result -> CommunityVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(post):
                    UserDefaults.isShowDailyGoalView = false
                    UserDefaults.oneDay = Date()
                    return .creatStaticPost(post)
                }
            }).eraseToAnyPublisher()
        
        let deletePost = input.deletePost
            .flatMap({ [unowned self] id -> AnyPublisher<Result<BaseResponse, ServerError>, Never> in
                postId = id
                return self.repository.deletePost(postId: id)
            })
            .receive(on: DispatchQueue.main)
            .map({ [unowned self] result -> CommunityVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case .success:
                    return self.updateDataSourceWhenDelete(postId: postId)
                }
            }).eraseToAnyPublisher()
        
        let dissmisAnotherVC = input.dismissCreateAndUpdatePublisher
            .flatMap { [unowned self] _ -> AnyPublisher<Result<Community, ServerError>, Never> in
                return self.repository.getPosts(model: createPaginationModel(isPaging: false))
            }
            .receive(on: DispatchQueue.main)
            .map { [unowned self] result -> CommunityVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(model):
                    return self.reloadDataSource(model: model.data)
                }
            }.eraseToAnyPublisher()
        
        let addRemoveLikePublisher = input.addRemoveLikePublisher
            .flatMap({ [unowned self] id -> AnyPublisher<Result<LikePost, ServerError>, Never> in
                return self.repository.addRemoveLike(postId: id)
            })
            .receive(on: DispatchQueue.main)
            .map({ [unowned self] result -> CommunityVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(post):
                    return self.changeSocialCounterButton(type: .like, likePost: post, commentPost: nil)
                }
            }).eraseToAnyPublisher()
        
        let addComment = input.addCommentPublisher
            .map({ [unowned self] post -> CommunityVCState in
                return self.changeSocialCounterButton(type: .comment, likePost: nil, commentPost: post)
            }).eraseToAnyPublisher()
        
       let shareSteps = NotificationCenter.default.publisher(for: .shareSteps)
            .flatMap({ [unowned self] _ -> AnyPublisher<Result<Post, ServerError>, Never> in
                self.router.redirectToCommunity()
                let steps = UserDefaults.stepsCount ?? 0
                return self.repository.createStaticPost(steps: String(steps))
            })
            .map({ result -> CommunityVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(post):
                    UserDefaults.isShowDailyGoalView = false
                    UserDefaults.oneDay = Date()
                    return .creatStaticPost(post)
                }
            }).eraseToAnyPublisher()
                
        return Publishers.Merge8(idle, deletePost, createStaticPost, dissmisAnotherVC, addRemoveLikePublisher, updateWithPadding, addComment, shareSteps).eraseToAnyPublisher()
    }
}

// MARK: - Extension
extension СommunityVM {
    
    // MARK: - Navigation
    func presentCreateEditVC(state: CreateEditVCState, post: LocalPost?, dismissPublisher: PassthroughSubject<String, Never>) {
        guard let user = UserDefaults.userModel, user.postAbility else {
            router.showBlockedAlert()
            return
        }
        router.presentCreateEditPostVC(state: state, post: post, dismissPublisher: dismissPublisher)
    }
    
    func presentLikesSharedVC(type: LikesSharedStartVCType, postId: String) {
        router.presentLikesSharedVC(type: type, postId: postId)
    }
    
    func navigationToProfile() {
        router.navigationToProfile()
    }
    
    func navigationToCreateComment(post: LocalPost, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType) {
        router.navigationToCreateCommentVC(post: post, addCommentPublisher: addCommentPublisher, viewType: viewType)
    }
    
    func navigateToCommentsList(post: LocalPost, addRemoveLikePublisher: PassthroughSubject<String, Never>, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType) {
        router.navigateToCommentsList(post: post, addRemoveLikePublisher: addRemoveLikePublisher, addCommentPublisher: addCommentPublisher, viewType: viewType)
    }
    
    // MARK: - Work with dataSource
    private func updateDataSourcewithPading(model: [Post]) -> CommunityVCState {
        let localyModel = model.map { LocalPost(post: $0) }
        var cells: [CommunityCellContent] = []
        let newModels = localyModel.filter({ model -> Bool in
            return !models.contains(where: { $0._id == model._id })
        })
        
        if tempDataSource.isEmpty {
            cells = configureStaticCells()
        }
        cells.append(contentsOf: newModels.compactMap(CommunityCellContent.init))
        
        tempDataSource += cells
        models += newModels
        isPagination = false
        
        return model.count == 20 ? .somePage(tempDataSource) : .lastPage(tempDataSource)
    }
    
    private func reloadDataSource(model: [Post]) -> CommunityVCState {
        let localyModel = model.map { LocalPost(post: $0) }
        var cells: [CommunityCellContent] = []
        models = localyModel
        cells = configureStaticCells()
        cells.append(contentsOf: localyModel.compactMap(CommunityCellContent.init))
        tempDataSource = cells
        return model.count == 20 ? .somePage(tempDataSource) : .lastPage(tempDataSource)
    }
    
    private func updateDataSourceWhenDelete(postId: String) -> CommunityVCState {
        var cells: [CommunityCellContent] = []
        
        cells = configureStaticCells()
        models.removeAll(where: { $0._id == postId })
        cells.append(contentsOf: models.compactMap(CommunityCellContent.init))
        tempDataSource = cells
        return .deletePost(tempDataSource)
    }
    
    private func changeSocialCounterButton(type: SocialAction, likePost: LikePost?, commentPost: LocalPost?) -> CommunityVCState {
        var cells: [CommunityCellContent] = []
        var tempCells: [CommunityCellContent] = []
        tempCells = configureStaticCells()
        
        var state: CommunityVCState = .idle
        
        switch type {
        case .like:
            if let post = likePost, let index = models.firstIndex(where: { $0._id == post._id }) {
                let item = models[index]
                item.isLiked = post.isLiked
                item.likesCounter += post.isLiked ? 1 : -1
                cells.append(CommunityCellContent(post: item))
            }
        case .comment:
            if let post = commentPost, let index = models.firstIndex(where: { $0._id == post._id }) {
                let item = models[index]
                item.commentsCounter += 1
                cells.append(CommunityCellContent(post: item))
            }
        default: break
        }
        
        tempCells.append(contentsOf: models.compactMap(CommunityCellContent.init))
        state = .addSocialAction(cells, type)
        tempDataSource = tempCells
        
        return state
    }
    
    private func configureStaticCells() -> [CommunityCellContent] {
        isPassedMoreThan(days: 1, fromDate: UserDefaults.oneDay, toDate: Date())
        
        if let step = UserDefaults.stepsCount, step >= 5_000, UserDefaults.isShowDailyGoalView == true {
            return [.createPost]
        } else {
            return [.createPost]
        }
    }
    
    private func isPassedMoreThan(days: Int, fromDate date: Date?, toDate date2: Date) { // check how day passed (need to logic when show or hide dailyCell)
        let unitFlags: Set<Calendar.Component> = [.day]
        if let date = date, let deltaD = Calendar.current.dateComponents(unitFlags, from: date, to: date2).day, deltaD > days {
            UserDefaults.isShowDailyGoalView = true
        } else if date == nil {
            UserDefaults.isShowDailyGoalView = true
        }
        
    }
    
    private func createPaginationModel(isPaging: Bool) -> CommunityRequestModel {
        let page = isPaging ? Double(tempDataSource.count) / 20 + 1 : 1
        let counter = String(format: "%.0f", page)
        let model = CommunityRequestModel(limit: "20", counter: counter)
        return model
    }
}
