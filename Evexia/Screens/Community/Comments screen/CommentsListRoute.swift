//
//  CommentsListRoute.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 26.09.2021.
//

import Foundation
import Combine

// MARK: - CommentsListRoute
protocol CommentsListRoute {
    var commentsListTransition: Transition { get }
    
    func showCommentsList(post: LocalPost, addRemoveLikePublisher: PassthroughSubject<String, Never>, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType)
}

// MARK: - extension CommentsListRoute
extension CommentsListRoute where Self: RouterProtocol {
    func showCommentsList(post: LocalPost, addRemoveLikePublisher: PassthroughSubject<String, Never>, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType) {
        let vc = CommentsListBuilder.build(injector: injector, post: post, addRemoveLikePublisher: addRemoveLikePublisher, addCommentPublisher: addCommentPublisher, viewType: viewType)
        open(vc, transition: commentsListTransition)
    }
}
