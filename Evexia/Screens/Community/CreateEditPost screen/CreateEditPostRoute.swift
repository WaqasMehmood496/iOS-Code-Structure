//
//  CreatePostRoute.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 07.09.2021.
//

import UIKit
import Combine

// MARK: - CreateEditPostRoute
protocol CreateEditPostRoute {
    var createEditPostTransition: Transition { get }
    
    func presentCreateEditPost(state: CreateEditVCState, post: LocalPost?, dismissPublisher: PassthroughSubject<String, Never>
    )
}

// MARK: - Extension CreateEditPostRoute
extension CreateEditPostRoute where Self: RouterProtocol {
    func presentCreateEditPost(state: CreateEditVCState, post: LocalPost?, dismissPublisher: PassthroughSubject<String, Never>) {
        let vc = CreateEditPostBuilder.build(injector: injector, state: state, post: post, dismissPublisher: dismissPublisher)
        open(vc, transition: createEditPostTransition)
    }
}
