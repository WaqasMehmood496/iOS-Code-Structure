//
//  CreateCommentRepository.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 20.09.2021.
//

import Foundation
import Combine

// MARK: - CreateCommentRepositoryProtocol
protocol CreateCommentRepositoryProtocol {
    func createComment(postId: String, content: String, ids: [String]) -> AnyPublisher<Result<CommentResponseModel, ServerError>, Never>
    func searchUsers(text: String) -> AnyPublisher<[CommunityUser], ServerError>

}

// MARK: - CreateCommentRepository
class CreateCommentRepository {
    
    // MARK: - Properties
    private var communityNetworkProvider: CommunityNetworkProviderProtocol
    
    // MARK: - Init
    init(communityNetworkProvider: CommunityNetworkProviderProtocol) {
        self.communityNetworkProvider = communityNetworkProvider
    }
}

// MARK: - CreateCommentRepository: CreateCommentRepositoryProtocol
extension CreateCommentRepository: CreateCommentRepositoryProtocol {
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
    
    func searchUsers(text: String) -> AnyPublisher<[CommunityUser], ServerError> {
       return communityNetworkProvider.searchUser(name: text)
    }
}
