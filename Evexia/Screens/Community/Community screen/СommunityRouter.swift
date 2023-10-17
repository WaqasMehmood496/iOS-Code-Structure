//
//  СommunityRouter.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import Foundation
import Combine

// MARK: - СommunityRouterRoutes
typealias СommunityRouterRoutes = CreateEditPostRoute & RootRoute & LikesSharedRoute & CreateCommentRoute & CommentsListRoute

// MARK: - CommunityNavigation: СommunityRouterRoutes
protocol CommunityNavigation: СommunityRouterRoutes {
    func presentCreateEditPostVC(state: CreateEditVCState, post: LocalPost?, dismissPublisher: PassthroughSubject<String, Never>)
    func navigationToProfile()
    func presentLikesSharedVC(type: LikesSharedStartVCType, postId: String)
    func navigationToCreateCommentVC(post: LocalPost, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType)
    func navigateToCommentsList(post: LocalPost, addRemoveLikePublisher: PassthroughSubject<String, Never>, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType)
    func showBlockedAlert()
    func redirectToCommunity()
}

// MARK: - СommunityRouter
class СommunityRouter: Router<CommunityVC>, CommunityNavigation {
    
    var commentsListTransition: Transition {
        return ModalTransition(modalPresentationStyle: .automatic)
    }
    
    var createCommentTransition: Transition {
        return ModalTransition(modalPresentationStyle: .automatic)
    }
    
    var likesSharedTransition: Transition {
        return ModalTransition(modalPresentationStyle: .automatic)
    }
    
    var rootTransition: Transition {
        return RootTransition(removeNavigation: true)
    }
    
    var createEditPostTransition: Transition {
        return ModalTransition(modalPresentationStyle: .automatic)
    }
    
    func presentLikesSharedVC(type: LikesSharedStartVCType, postId: String) {
        presentLikesShared(type: type, postId: postId)
    }
    
    func presentCreateEditPostVC(state: CreateEditVCState, post: LocalPost?, dismissPublisher: PassthroughSubject<String, Never>
    ) {
        presentCreateEditPost(state: state, post: post, dismissPublisher: dismissPublisher)
    }
    
    func navigationToProfile() {
        showRoot()
    }
    
    func navigationToCreateCommentVC(post: LocalPost, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType) {
        showCreateComment(post: post, addCommentPublisher: addCommentPublisher, viewType: viewType)
    }
    
    func navigateToCommentsList(post: LocalPost, addRemoveLikePublisher: PassthroughSubject<String, Never>, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType) {
        showCommentsList(post: post, addRemoveLikePublisher: addRemoveLikePublisher, addCommentPublisher: addCommentPublisher, viewType: viewType)
    }
    
    func showBlockedAlert() {
        self.viewController?.modalAlert(modalStyle: ServerError(errorCode: .dissabledPostingAndCommenting).errorCode)
    }
    
    func redirectToCommunity() {
        self.viewController?.tabBarController?.selectedIndex = TabBarItemType.community.rawValue
    }
}
