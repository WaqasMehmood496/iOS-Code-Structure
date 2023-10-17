//
//  ProfileBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 28.07.2021.
//

import Foundation
import Swinject

class ProfileEditBuilder {
    static func build(injector: Container, nextViewTrigger: @escaping () -> Void?, profileFlow: ProfileEditScreenFlow) -> ProfileEditVC {
        let vc = ProfileEditVC.board(name: .profileEdit)
        let router = ProfileEditRouter(injector: injector)
        router.viewController = vc
        let repository = ProfileEditRepository(userNetworkProvider: injector.resolve(UserNetworkProvider.self)!, profileFlow: profileFlow)
        
        let viewModel = ProfileEditVM(router: router, repository: repository, profileFlow: profileFlow)
        vc.viewModel = viewModel

        return vc
    }
}
