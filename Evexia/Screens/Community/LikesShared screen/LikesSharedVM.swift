//
//  LikesSharedVM.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 09.09.2021.
//

import Foundation
import Combine

// MARK: - LikesSharedVM
class LikesSharedVM: LikesSharedVMType {
    
    // MARK: - Properties
    let startVCType: LikesSharedStartVCType
    private let postId: String
    private let router: LikesSharedNavigation
    private let repository: LikesSharedRepositoryProtocol
    
    // MARK: - Init
    init(
        router: LikesSharedNavigation,
        repository: LikesSharedRepositoryProtocol,
        startVCType: LikesSharedStartVCType,
        postId: String
    ) {
        self.router = router
        self.repository = repository
        self.startVCType = startVCType
        self.postId = postId
    }
    
    // MARK: - Methods
    func transform(input: LikesSharedVMInput) -> LikesSharedVMOutput {
        let idle = input.appear
            .flatMap({ [unowned self] state -> AnyPublisher<Result<[LikeAndShares], ServerError>, Never> in
                switch state {
                case .likes:
                    return self.repository.getLikes(postId: postId)
                case .shares:
                    return self.repository.getShares(postId: postId)
                }
            })
            .receive(on: DispatchQueue.main)
            .map({ result -> LikesSharedVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(list):
                    return .success(list)
                }
            }).eraseToAnyPublisher()
        
        return idle
    }
}
