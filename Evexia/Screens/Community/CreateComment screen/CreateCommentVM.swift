//
//  CreateCommentVM.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 20.09.2021.
//

import Combine
import Foundation

// MARK: - CreateCommentVM
class CreateCommentVM: CreateCommentVMType {
    
    // MARK: - Properties
    let viewType: PostViewType
    private let repository: CreateCommentRepositoryProtocol
    private let router: CreateCommentNavigation
    private let post: LocalPost
    private var cancellables = Set<AnyCancellable>()
    private var addCommentPublisher: PassthroughSubject<LocalPost, Never>
    var communityUsers = CurrentValueSubject<[CommunityUser], Never>([])
    var companyUsers = [CommunityUser]()
    
    // MARK: - Init
    init(repository: CreateCommentRepositoryProtocol, router: CreateCommentNavigation, post: LocalPost, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType) {
        self.repository = repository
        self.router = router
        self.post = post
        self.addCommentPublisher = addCommentPublisher
        self.viewType = viewType
        self.getAllUsers()

    }
    
    // MARK: - Methods
    func transform(input: CreateCommentVMInput) -> CreateCommentVMOutput {

        let idle = input.appear
            .map { [unowned self] _ -> CreateCommentVCState in
                return .idle(self.post)
            }.eraseToAnyPublisher()
        
        let createComment = input.createComment
            .flatMap({ [unowned self] content, tags -> AnyPublisher<Result<CommentResponseModel, ServerError>, Never> in
                let users = tags.compactMap { tag in
                    self.companyUsers.first(where: { $0.username == tag })
                }
                let ids = users.map { $0.id }

                return self.repository.createComment(postId: post._id, content: content, ids: ids)
            })
            .receive(on: DispatchQueue.main)
            .map({ result -> CreateCommentVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(comment):
                    self.addCommentPublisher.send(self.post)
                    return .createComment(comment)
                }
            }).eraseToAnyPublisher()
        
        return Publishers.Merge(idle, createComment).eraseToAnyPublisher()
    }
    
    func getAllUsers() {
        self.repository.searchUsers(text: "")
            .sink(receiveCompletion: { _ in },
            receiveValue: { [weak self] users in
                self?.companyUsers = users
            }).store(in: &self.cancellables)
    }
    
    
    func searchUsers(_ text: String) {
        self.repository.searchUsers(text: text)
            .sink(receiveCompletion: { _ in
                
            },
            receiveValue: { [weak self] users in
                
                self?.communityUsers.send(users)
            }).store(in: &self.cancellables)
    }
}
