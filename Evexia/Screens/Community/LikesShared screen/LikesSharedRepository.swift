//
//  LikesSharedRepository.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 09.09.2021.
//

import Foundation
import Combine

// MARK: - LikesSharedRepositoryProtocol
protocol LikesSharedRepositoryProtocol {
    func getLikes(postId: String) -> AnyPublisher<Result<[LikeAndShares], ServerError>, Never>
    func getShares(postId: String) -> AnyPublisher<Result<[LikeAndShares], ServerError>, Never>
}

// MARK: - LikesSharedRepository
class LikesSharedRepository {
    
    // MARK: - Properties
    private let communityNetworkProvider: CommunityNetworkProviderProtocol
    
    // MARK: - Init
    init(communityNetworkProvider: CommunityNetworkProviderProtocol) {
        self.communityNetworkProvider = communityNetworkProvider
    }
    
}

// MARK: - Extension with LikesSharedRepositoryProtocol
extension LikesSharedRepository: LikesSharedRepositoryProtocol {
    func getLikes(postId: String) -> AnyPublisher<Result<[LikeAndShares], ServerError>, Never> {
        communityNetworkProvider.getLikes(postId: postId)
            .map({ response -> Result<[LikeAndShares], ServerError> in
                return .success(response)
            })
            .catch({ error -> AnyPublisher<Result<[LikeAndShares], ServerError>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func getShares(postId: String) -> AnyPublisher<Result<[LikeAndShares], ServerError>, Never> {
        communityNetworkProvider.getShares(postId: postId)
            .map({ response -> Result<[LikeAndShares], ServerError> in
                return .success(response)
            })
            .catch({ error -> AnyPublisher<Result<[LikeAndShares], ServerError>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
}
