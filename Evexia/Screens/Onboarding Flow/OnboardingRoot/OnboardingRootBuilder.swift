//
//  OnboardingRootBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import UIKit
import Swinject

class OnboardingRootBuilder {
    static func build(injector: Container, profileFlow: ProfileEditScreenFlow) -> OnboardingRootVC {
        let rootVC = OnboardingRootVC.board(name: .onboardingRoot)
        let router = OnboardingRootRouter(injector: injector)
        router.viewController = rootVC
        let vm = OnboardingRootVM(router: router, profileFlow: profileFlow)
        rootVC.viewModel = vm
        return rootVC
    }
}
