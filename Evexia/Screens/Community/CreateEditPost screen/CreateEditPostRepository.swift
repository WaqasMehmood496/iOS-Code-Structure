//
//  CreatePostRepository.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 07.09.2021.
//

import Combine
import Foundation

// MARK: - CreateEditPostRepositoryProtocol
protocol CreateEditPostRepositoryProtocol {
    func createPost(model: CreatePostRequestModel) -> AnyPublisher<Result<Post, ServerError>, Never>
    func editPost(editPost: CreatePostRequestModel, postId: String, employees: [String]) -> AnyPublisher<Result<Post, ServerError>, Never>
    func uploadImage(data: [Data]) -> AnyPublisher<Result<[Attachments], ServerError>, Never>
    func uploadVideo(data: Data) -> AnyPublisher<Result<Attachments, ServerError>, Never>
    func searchUsers(text: String) -> AnyPublisher<[CommunityUser], ServerError>
}

// MARK: - CreateEditPostRepository
class CreateEditPostRepository {

    // MARK: - Properties
    private var communityNetworkProvider: CommunityNetworkProviderProtocol
    
    init(communityNetworkProvider: CommunityNetworkProviderProtocol) {
        self.communityNetworkProvider = communityNetworkProvider
    }
    
}

// MARK: - CreateEditPostRepository: CreateEditPostRepositoryProtocol
extension CreateEditPostRepository: CreateEditPostRepositoryProtocol {
    
    func createPost(model: CreatePostRequestModel) -> AnyPublisher<Result<Post, ServerError>, Never> {
        communityNetworkProvider.createPost(model: model)
            .map({ response -> Result<Post, ServerError> in
                return .success(response)
            })
            .catch({ error -> AnyPublisher<Result<Post, ServerError>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func editPost(editPost: CreatePostRequestModel, postId: String, employees: [String]) -> AnyPublisher<Result<Post, ServerError>, Never> {
        communityNetworkProvider.editPost(model: editPost, postId: postId, employees: employees)
            .map({ response -> Result<Post, ServerError> in
                .success(response)
            })
            .catch({ error -> AnyPublisher<Result<Post, ServerError>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func uploadImage(data: [Data]) -> AnyPublisher<Result<[Attachments], ServerError>, Never> {
        communityNetworkProvider.uploadImage(data: data)
            .map({ response -> Result<[Attachments], ServerError> in
                return .success(response)
            })
            .catch({ error -> AnyPublisher<Result<[Attachments], ServerError>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func uploadVideo(data: Data) -> AnyPublisher<Result<Attachments, ServerError>, Never> {
        communityNetworkProvider.uploadVideo(data: data)
            .map({ response -> Result<Attachments, ServerError> in
                return .success(response)
            })
            .catch({ error -> AnyPublisher<Result<Attachments, ServerError>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func searchUsers(text: String) -> AnyPublisher<[CommunityUser], ServerError> {
       return communityNetworkProvider.searchUser(name: text)
    }
}
