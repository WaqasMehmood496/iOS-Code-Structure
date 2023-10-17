//
//  OnboardingRootRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 19.07.2021.
//

import Foundation

protocol OnboardingRootRoute {
    func showOnboardingRoot(profileFlow: ProfileEditScreenFlow)
    
    var onboardingRootTransition: Transition { get }
    
    var changeOnboardingRooTransition: Transition { get }
}

extension OnboardingRootRoute where Self: RouterProtocol {
    func showOnboardingRoot(profileFlow: ProfileEditScreenFlow) {
        let vc = OnboardingRootBuilder.build(injector: injector, profileFlow: profileFlow)
        open(vc, transition: profileFlow == .changePlanAfterEndPeriod ? changeOnboardingRooTransition : onboardingRootTransition)
    }
}
