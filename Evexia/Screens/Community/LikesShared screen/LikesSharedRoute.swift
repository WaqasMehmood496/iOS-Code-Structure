//
//  LikesSharedRoute.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 09.09.2021.
//

import Foundation

// MARK: - LikesSharedRoute
protocol LikesSharedRoute {
    var likesSharedTransition: Transition { get }
    
    func presentLikesShared(type: LikesSharedStartVCType, postId: String)
}

// MARK: - Extension
extension LikesSharedRoute where Self: RouterProtocol {
    func presentLikesShared(type: LikesSharedStartVCType, postId: String) {
        let vc = LikesSharedBuilder.build(injector: injector, type: type, postId: postId)
        open(vc, transition: likesSharedTransition)
    }
}
