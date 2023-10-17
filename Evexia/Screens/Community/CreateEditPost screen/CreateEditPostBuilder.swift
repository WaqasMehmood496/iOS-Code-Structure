//
//  CreatePostBuilder.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 07.09.2021.
//

import UIKit
import Swinject
import Combine

// MARK: - CreateEditPostBuilder
class CreateEditPostBuilder {
    class func build(injector: Container, state: CreateEditVCState, post: LocalPost?, dismissPublisher: PassthroughSubject<String, Never>) -> CreateEditPostVC {
        
        let vc = CreateEditPostVC.board(name: .communityCreateEditPost)
        let router = CreateEditPostRouter(injector: injector)
        router.viewController = vc
        let repository = CreateEditPostRepository(communityNetworkProvider: injector.resolve(CommunityNetworkProvider.self)!)
        
        let createEditPostVM = CreateEditPostVM(repository: repository, router: router, startVCState: state, post: post, dismissPublisher: dismissPublisher)
        
        vc.viewModel = createEditPostVM
        
        return vc
    }
}
