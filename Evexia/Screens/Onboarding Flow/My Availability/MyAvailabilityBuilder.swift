//
//  MyAvailabilityBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 21.07.2021.
//

import Foundation
import Swinject

class MyAvailabilityBuilder {
    static func build(injector: Container, nextViewTrigger: (() -> Void)?, profileFlow: ProfileEditScreenFlow) -> MyAvailabilityVC {
        let vc = MyAvailabilityVC.board(name: .myAvailability)
        let router = MyAvailabilityRouter(injector: injector)
        router.viewController = vc
        router.nextViewTrigger = nextViewTrigger
        let repository = MyAvailabilityRepository(networkProvider: injector.resolve(OnboardingNetworkProvider.self)!)
        
        let viewModel = MyAvailabilityVM(router: router, repository: repository, profileFlow: profileFlow)
        vc.viewModel = viewModel
        return vc
    }
}
