//
//  СommunityBuilder.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import UIKit
import Swinject

// MARK: - СommunityBuilder
class СommunityBuilder {
    class func build(injector: Container) -> CommunityVC {
        let vc = CommunityVC.board(name: .community)
        let router = СommunityRouter(injector: injector)
        router.viewController = vc
        let repository = CommunityRepository(communityNetworkProvider: injector.resolve(CommunityNetworkProvider.self)!)
        
        let communityVM = СommunityVM(repository: repository, router: router)
        vc.viewModel = communityVM
        return vc
    }
}
