//
//  OnboardingFactory.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 18.07.2021.
//

import Foundation
import Swinject
import UIKit

final class OnboardingBuilder {
    
    static func build(injector: Container) -> OnboardingVC {
        let vc = OnboardingVC.board(name: .onboarding)
        let router = OnboardingRouter(injector: injector)
        router.viewController = vc
        let repository = ProjectsRepository(onboardingNetworkProvider: injector.resolve(OnboardingNetworkProvider.self)!)
        vc.viewModel = OnboardingVM(router: router,
                                    repository: repository)
        return vc
    }
}
