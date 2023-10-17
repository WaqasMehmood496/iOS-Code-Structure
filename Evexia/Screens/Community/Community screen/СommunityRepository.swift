//
//  СommunityRepository.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import Foundation
import Combine

// MARK: - СommunityRepositoryProtocol
protocol СommunityRepositoryProtocol {
    func getPosts(model: CommunityRequestModel) -> AnyPublisher<Result<Community, ServerError>, Never>
    func deletePost(postId: String) -> AnyPublisher<Result<BaseResponse, ServerError>, Never>
    func createStaticPost(steps: String) -> AnyPublisher<Result<Post, ServerError>, Never>
    func addRemoveLike(postId: String) -> AnyPublisher<Result<LikePost, ServerError>, Never>
}

// MARK: - СommunityRepository
class CommunityRepository {
    
    // MARK: - Properties
    private var communityNetworkProvider: CommunityNetworkProviderProtocol
    
    init(communityNetworkProvider: CommunityNetworkProviderProtocol) {
        self.communityNetworkProvider = communityNetworkProvider
    }
}

// MARK: - СommunityRepository: СommunityRepositoryProtocol
extension CommunityRepository: СommunityRepositoryProtocol {
    func getPosts(model: CommunityRequestModel) -> AnyPublisher<Result<Community, ServerError>, Never> {
        communityNetworkProvider.getPosts(model: model)
            .map({ response -> Result<Community, ServerError> in
                return .success(response)
            })
            .catch({ error -> AnyPublisher<Result<Community, ServerError>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func createStaticPost(steps: String) -> AnyPublisher<Result<Post, ServerError>, Never> {
        communityNetworkProvider.createStaticPost(steps: steps)
            .map({ response -> Result<Post, ServerError> in
                return.success(response)
            })
            .catch({ error -> AnyPublisher<Result<Post, ServerError>, Never> in
                return.just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func deletePost(postId: String) -> AnyPublisher<Result<BaseResponse, ServerError>, Never> {
        communityNetworkProvider.deletePost(postId: postId)
            .map({ response -> Result<BaseResponse, ServerError> in
                return.success(response)
            })
            .catch({ error -> AnyPublisher<Result<BaseResponse, ServerError>, Never> in
                return.just(.failure(error))
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
}
