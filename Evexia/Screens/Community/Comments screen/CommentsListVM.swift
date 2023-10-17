//
//  CommentsListVM.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 26.09.2021.
//

import Foundation
import Combine

// MARK: - CommentsCellType
enum CommentsCellType: Hashable {
    case comment(CommentResponseModel)
    case reply(ReplyModel, String, Author)
    
    init(reply: ReplyModel, commentId: String, commentAuthor: Author) {
        self = .reply(reply, commentId, commentAuthor)
    }
    
    init(comment: CommentResponseModel) {
        self = .comment(comment)
    }
}

// MARK: - CommentsListVM
class CommentsListVM: CommentsListVMType {
    
    let post: LocalPost
    let viewType: PostViewType
    var isPagination: Bool = false
    var isReadyToPagination: Bool = false
    var communityUsers = CurrentValueSubject<[CommunityUser], Never>([])
    var companyUsers = [CommunityUser]()
    
    private let repository: CommentsListRepositoryProtocol
    private let router: CommentsListNavigation
    private var tempDataSource: [CommentsCellType] = []
    private var tempComments: [CommentResponseModel] = []
    private var cancellables = Set<AnyCancellable>()
    private var addRemoveLikePublisher: PassthroughSubject<String, Never>
    private var addCommentPublisher: PassthroughSubject<LocalPost, Never>
    private var commentId: String = ""
    
    // MARK: - Init
    init(repository: CommentsListRepositoryProtocol, router: CommentsListNavigation, post: LocalPost, addRemoveLikePublisher: PassthroughSubject<String, Never>, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType) {
        self.repository = repository
        self.router = router
        self.post = post
        self.addRemoveLikePublisher = addRemoveLikePublisher
        self.addCommentPublisher = addCommentPublisher
        self.viewType = viewType
        self.getAllUsers()
    }
    
    // MARK: - Methods
    func transform(input: CommentsListVMInput) -> CommentsListVMOutput {
        
        let idle = input.appear
            .map({ [unowned self] _ -> CommentsListVCState in
                return .idle(self.post)
            }).eraseToAnyPublisher()
        
        let loadComments = input.loadComments
            .flatMap({ [unowned self] _ -> AnyPublisher<Result<[CommentResponseModel], ServerError>, Never> in
                return self.repository.getComments(postId: post._id, model: createPaginationModel(isPaging: false))
            })
            .receive(on: DispatchQueue.main)
            .map({ [unowned self] result -> CommentsListVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(comments):
                    return self.createCommentsCellModel(comments: comments)
                }
            }).eraseToAnyPublisher()
        
        let createComment = input.createComment
            .flatMap({ [unowned self] content, tags -> AnyPublisher<Result<CommentResponseModel, ServerError>, Never> in
                let users = tags.compactMap { tag in
                    self.companyUsers.first(where: { $0.username == tag })
                }
                let ids = users.map { $0.id }
                
                return self.repository.createComment(postId: post._id, content: content, ids: ids)
            })
            .receive(on: DispatchQueue.main)
            .map({ [unowned self] result -> CommentsListVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(comment):
                    self.addCommentPublisher.send(self.post)
                    return updateDataSourceWhenCreate(comment: comment)
                }
            }).eraseToAnyPublisher()
        
        let addReply = input.addReply
            .flatMap({ [unowned self] content, commentId, replyModel, tags -> AnyPublisher<Result<ReplyModel, ServerError>, Never> in
                self.commentId = commentId
                let users = tags.compactMap { tag in
                    self.companyUsers.first(where: { $0.username == tag })
                }
                let ids = users.map { $0.id }
                return self.repository.addReply(postId: post._id, commentId: commentId, content: content, replyToModel: replyModel, ids: ids)
            })
            .receive(on: DispatchQueue.main)
            .map({ [unowned self] result -> CommentsListVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(reply):
                    self.addCommentPublisher.send(self.post)
                    return self.updateDataSourceWhenCreate(reply: reply)
                }
            }).eraseToAnyPublisher()
        
        let addRemoveLikePublisher = input.addRemoveLikePublisher
            .map({ [unowned self] id -> CommentsListVCState in
                self.addRemoveLikePublisher.send(id)
                return .addRemoveLike
            }).eraseToAnyPublisher()
        
        let updateComments = input.updateComments
            .flatMap({ [unowned self] _ -> AnyPublisher<Result<[CommentResponseModel], ServerError>, Never> in
                return self.repository.getComments(postId: post._id, model: createPaginationModel(isPaging: true))
            })
            .receive(on: DispatchQueue.main)
            .map({ [unowned self] result -> CommentsListVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(comments):
                    return self.updateDataSourcewithPading(comments: comments)
                }
            }).eraseToAnyPublisher()
        
        return Publishers.Merge6(idle, loadComments, addReply, createComment, addRemoveLikePublisher, updateComments).eraseToAnyPublisher()
    }
    
    func openURL(url: URL, dismissSocialWebView: PassthroughSubject<Int?, Never>) {
        router.openURL(url: url, dismissSocialWebView: dismissSocialWebView)
    }
    
    func getAllUsers() {
        self.repository.searchUsers(text: "")
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] users in
                    self?.companyUsers = users
            }).store(in: &self.cancellables)
    }
}

// MARK: - Private Extension
extension CommentsListVM {
    private func createPaginationModel(isPaging: Bool) -> CommunityRequestModel {
        let page = isPaging ? Double(tempDataSource.count) / 20 + 1 : 1
        let counter = String(format: "%.0f", page)
        let model = CommunityRequestModel(limit: "20", counter: counter)
        return model
    }
    
    private func createCommentsCellModel(comments: [CommentResponseModel]) -> CommentsListVCState {
        var cells: [CommentsCellType] = []
        
        comments.forEach { comment in
            cells.append(.init(comment: comment))
            cells.append(contentsOf: comment.reply.compactMap { .init(reply: $0, commentId: comment._id, commentAuthor: $0.author) })
        }
        tempDataSource = cells
        tempComments = comments
        
        return comments.count == 20 ? .somePage(tempDataSource) : .lastPage(tempDataSource)
    }
    
    private func updateDataSourcewithPading(comments: [CommentResponseModel]) -> CommentsListVCState {
        var cells: [CommentsCellType] = []
        
        comments.forEach { comment in
            cells.append(.init(comment: comment))
            cells.append(contentsOf: comment.reply.compactMap { .init(reply: $0, commentId: comment._id, commentAuthor: $0.author) })
        }
        
        tempDataSource += cells
        tempComments += comments
        isPagination = false
        
        return comments.count == 20 ? .somePage(tempDataSource) : .lastPage(tempDataSource)
    }
    
    private func updateDataSourceWhenCreate(comment: CommentResponseModel) -> CommentsListVCState {
        var cells: [CommentsCellType] = []
        tempComments.insert(comment, at: 0)
        tempComments.forEach { comment in
            cells.append(.init(comment: comment))
            cells.append(contentsOf: comment.reply.compactMap { .init(reply: $0, commentId: comment._id, commentAuthor: $0.author) })
        }
        
        tempDataSource = cells
        
        return .addComment(tempDataSource)
    }
    
    private func updateDataSourceWhenCreate(reply: ReplyModel) -> CommentsListVCState {
        var cells: [CommentsCellType] = []
        if let index = tempComments.firstIndex(where: { $0._id == commentId }) {
            tempComments[index].addReply(reply: reply)
        }
        
        tempComments.forEach { comment in
            cells.append(.init(comment: comment))
            cells.append(contentsOf: comment.reply.compactMap { .init(reply: $0, commentId: comment._id, commentAuthor: $0.author) })
        }
        
        tempDataSource = cells
        
        return .addReply(tempDataSource, reply._id)
    }
    
    func searchUsers(_ text: String) {
        self.repository.searchUsers(text: text)
            .sink(receiveCompletion: { _ in },
                receiveValue: { [weak self] users in
                    self?.communityUsers.send(users)
                }).store(in: &self.cancellables)
    }
}
