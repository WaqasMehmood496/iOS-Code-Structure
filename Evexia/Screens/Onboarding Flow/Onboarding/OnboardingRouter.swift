//
//  OnboardingRouter.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 18.07.2021.
//

import Foundation

// MARK: - OnboardingRouterRoutes
typealias OnboardingRoutes = OnboardingRootRoute & RootRoute

protocol OnboardingNavigation: OnboardingRoutes {
    
    func navigateToPersonalPlan(profileFlow: ProfileEditScreenFlow)
    func navigateToRoot()
    
}

class OnboardingRouter: Router<OnboardingVC>, OnboardingNavigation {
    
    var changeOnboardingRooTransition: Transition {
        return PushTransition()
    }
    
    var rootTransition: Transition {
        return RootTransition()
    }
    
    var onboardingRootTransition: Transition {
        return RootTransition()
    }
    
    func navigateToPersonalPlan(profileFlow: ProfileEditScreenFlow) {
        self.showOnboardingRoot(profileFlow: profileFlow)
    }
    func navigateToRoot() {
        self.showRoot()
    }
}
