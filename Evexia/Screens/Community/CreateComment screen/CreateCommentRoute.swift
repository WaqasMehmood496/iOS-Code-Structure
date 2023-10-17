//
//  CreateCommentRoute.swift
//  Evexia Staging
//
//  Created by Oleksandr Kovalov on 20.09.2021.
//

import Foundation
import Combine

// MARK: - CreateCommentRoute
protocol CreateCommentRoute {
    var createCommentTransition: Transition { get }
    
    func showCreateComment(post: LocalPost, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType)
}

// MARK: - extension CreateCommentRoute
extension CreateCommentRoute where Self: RouterProtocol {
    func showCreateComment(post: LocalPost, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType) {
        let vc = CreateCommentBuilder.build(injector: injector, post: post, addCommentPublisher: addCommentPublisher, viewType: viewType)
        open(vc, transition: createCommentTransition)
    }
}
