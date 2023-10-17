//
//  PersonalPlanBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import Foundation
import Swinject
 
class PersonalPlanBuilder {
    static func build(injector: Container, nextViewTrigger: @escaping () -> Void) -> PersonalPlanVC {
        let vc = PersonalPlanVC.board(name: .personalPlan)
        let router = PersonalPlanRouter(injector: injector)
        router.viewController = vc
        router.nextViewTrigger = nextViewTrigger
        let repository = PersonalPlanRepository(onboardingNetworkProvider: injector.resolve(OnboardingNetworkProvider.self)!)
        let vm = PersonalPlanVM(router: router, repository: repository)
        vc.viewModel = vm
        return vc
    }
}
