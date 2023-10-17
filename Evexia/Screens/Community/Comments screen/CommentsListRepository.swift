//
//  CommentsListRepository.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 26.09.2021.
//

import Foundation
import Combine
// MARK: - CommentsListRepositoryProtocol
protocol CommentsListRepositoryProtocol {
    func getComments(postId: String, model: CommunityRequestModel) -> AnyPublisher<Result<[CommentResponseModel], ServerError>, Never>
    func addReply(postId: String, commentId: String, content: String, replyToModel: ReplyToModel, ids: [String]) -> AnyPublisher<Result<ReplyModel, ServerError>, Never>
    func createComment(postId: String, content: String, ids: [String]) -> AnyPublisher<Result<CommentResponseModel, ServerError>, Never>
    func addRemoveLike(postId: String) -> AnyPublisher<Result<LikePost, ServerError>, Never>
    func searchUsers(text: String) -> AnyPublisher<[CommunityUser], ServerError>
}

// MARK: - CommentsListRepository
class CommentsListRepository {
    
    // MARK: - Properties
    private var communityNetworkProvider: CommunityNetworkProviderProtocol
    
    init(communityNetworkProvider: CommunityNetworkProviderProtocol) {
        self.communityNetworkProvider = communityNetworkProvider
    }
}

// MARK: - CommentsListRepository: CommentsListRepositoryProtocol
extension CommentsListRepository: CommentsListRepositoryProtocol {
    func getComments(postId: String, model: CommunityRequestModel) -> AnyPublisher<Result<[CommentResponseModel], ServerError>, Never> {
        communityNetworkProvider.getComments(postId: postId, model: model)
            .map({ response -> Result<[CommentResponseModel], ServerError> in
                return .success(response)
            })
            .catch({ error -> AnyPublisher<Result<[CommentResponseModel], ServerError>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func addReply(postId: String, commentId: String, content: String, replyToModel: ReplyToModel, ids: [String]) -> AnyPublisher<Result<ReplyModel, ServerError>, Never> {
        communityNetworkProvider.addReply(postId: postId, commentId: commentId, content: content, replyToModel: replyToModel, ids: ids)
            .map({ response -> Result<ReplyModel, ServerError> in
                return .success(response)
            })
            .catch({ error -> AnyPublisher<Result<ReplyModel, ServerError>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func createComment(postId: String, content: String, ids: [String]) -> AnyPublisher<Result<CommentResponseModel, ServerError>, Never> {
        communityNetworkProvider.createComment(postId: postId, content: content, ids: ids)
            .map({ response -> Result<CommentResponseModel, ServerError> in
                return .success(response)
            })
            .catch({ error -> AnyPublisher<Result<CommentResponseModel, ServerError>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func addRemoveLike(postId: String) -> AnyPublisher<Result<LikePost, ServerError>, Never> {
        communityNetworkProvider.addRemoveLike(postId: postId)
            .map({ response -> Result<LikePost, ServerError> in
                return.success(response)
            })
            .catch({ error -> AnyPublisher<Result<LikePost, ServerError>, Never> in
                return.just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func searchUsers(text: String) -> AnyPublisher<[CommunityUser], ServerError> {
       return communityNetworkProvider.searchUser(name: text)
    }
}
