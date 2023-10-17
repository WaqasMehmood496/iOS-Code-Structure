//
//  VerificationRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 01.07.2021.
//

import Foundation

// MARK: - SignUpRouterRoutes
typealias VerificationRouterRoutes = SignUpRoute & OnboardingRoute

protocol VerificationNavigation: VerificationRouterRoutes {
    func navigateToSignUp()
    func navigateToOnboarding()
}

class VerificationRouter: Router<VerificationVC>, VerificationNavigation {
    var signUpTransition: Transition {
        return RootTransition()
    }
    
    var onboardingTransition: Transition {
       return ReplacingPushTransition()
    }
    
    func navigateToSignUp() {
        self.showSignUp()
    }
    
    func navigateToOnboarding() {
        self.showOnboarding()
    }
}
