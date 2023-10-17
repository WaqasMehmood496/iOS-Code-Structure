//
//  MyWhyBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 13.07.2021.
//

import Foundation
import Swinject

class MyWhyBuilder {
    static func build(injector: Container, nextViewTrigger: @escaping () -> Void) -> MyWhyVC {
        let vc = MyWhyVC.board(name: .myWhy)
        let router = MyWhyRouter(injector: injector)
        router.viewController = vc
        router.nextViewTrigger = nextViewTrigger
        let repository = MyWhyRepository(onboardingNetworkProvider: injector.resolve(OnboardingNetworkProvider.self)!)
        
        let viewModel = MyWhyVM(router: router, repository: repository)
        vc.viewModel = viewModel
        return vc
    }
}
