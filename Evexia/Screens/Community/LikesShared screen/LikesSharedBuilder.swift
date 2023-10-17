//
//  LikesSharedBuilder.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 09.09.2021.
//

import Swinject

// MARK: - LikesSharedBuilder
class LikesSharedBuilder {
    class func build(
        injector: Container,
        type: LikesSharedStartVCType,
        postId: String
    ) -> LikesSharedVC {
        let vc = LikesSharedVC.board(name: .likesShared)
        let router = LikesSharedRouter(injector: injector)
        router.viewController = vc
        let repository = LikesSharedRepository(communityNetworkProvider: injector.resolve(CommunityNetworkProvider.self)!)
        
        let viewModel = LikesSharedVM(
            router: router,
            repository: repository,
            startVCType: type,
            postId: postId
        )
        
        vc.viewModel = viewModel
        
        return vc
    }
}
