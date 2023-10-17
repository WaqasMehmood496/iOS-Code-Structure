//
//  CreateCommentBuilder.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 20.09.2021.
//

import Foundation
import Swinject
import Combine

// MARK: - CreateCommentBuilder
class CreateCommentBuilder {
    class func build(injector: Container, post: LocalPost, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType) -> CreateCommentVC {
        let vc = CreateCommentVC.board(name: .createComment)
        let router = CreateCommentRouter(injector: injector)
        router.viewController = vc
        let repository = CreateCommentRepository(communityNetworkProvider: injector.resolve(CommunityNetworkProvider.self)!)
        
        let createCommentVM = CreateCommentVM(repository: repository, router: router, post: post, addCommentPublisher: addCommentPublisher, viewType: viewType)
        vc.viewModel = createCommentVM
        
        return vc
    }
}
