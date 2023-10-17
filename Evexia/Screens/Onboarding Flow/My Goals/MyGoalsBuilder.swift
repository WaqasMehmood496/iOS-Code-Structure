//
//  MyGoalsBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 19.07.2021.
//

import Foundation
import Swinject

class MyGoalsBuilder {
    static func build(injector: Container, nextViewTrigger: @escaping () -> Void) -> MyGoalsVC {
        let vc = MyGoalsVC.board(name: .myGoals)
        let router = MyGoalsRouter(injector: injector)
        router.viewController = vc
        router.nextViewTrigger = nextViewTrigger

        let repository = MyGoalsRepository(onboardingNetworkProvider: injector.resolve(OnboardingNetworkProvider.self)!)
        
        let viewModel = MyGoalsVM(router: router, repository: repository)
        vc.viewModel = viewModel
        return vc
    }
}
