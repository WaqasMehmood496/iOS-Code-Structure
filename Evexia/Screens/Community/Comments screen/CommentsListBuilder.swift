//
//  CommentsListBuilder.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 26.09.2021.
//

import Foundation
import Swinject
import Combine

// MARK: - CommentsListBuilder
class CommentsListBuilder {
    class func build(injector: Container, post: LocalPost, addRemoveLikePublisher: PassthroughSubject<String, Never>, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType) -> CommentsListVC {
        let vc = CommentsListVC.board(name: .commentsList)
        let router = CommentsListRouter(injector: injector)
        router.viewController = vc
        let repository = CommentsListRepository(communityNetworkProvider: injector.resolve(CommunityNetworkProvider.self)!)
        
        let commentsListVM = CommentsListVM(repository: repository, router: router, post: post, addRemoveLikePublisher: addRemoveLikePublisher, addCommentPublisher: addCommentPublisher, viewType: viewType)
        vc.viewModel = commentsListVM
        return vc
    }
}
