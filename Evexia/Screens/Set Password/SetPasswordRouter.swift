//
//  SetPasswordRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 06.07.2021.
//

import Foundation

// MARK: - SignUpRouterRoutes
 typealias SetPasswordRoutes = SignInRoute & RootRoute & OnboardingRoute

protocol SetPasswordNavigation: SetPasswordRoutes {
    func navigateToSignIn()
    func navigateToRoot()
    func navigateToOnboarding()
}

class SetPasswordRouter: Router<SetPasswordVC>, SetPasswordNavigation {
    
    var signInTransition: Transition {
        return RootTransition()
    }
    
    var rootTransition: Transition {
        return RootTransition(removeNavigation: true)
    }
    
    var onboardingTransition: Transition {
        return RootTransition()
    }
    
    func navigateToSignIn() {
        self.showSignIn()
    }
    
    func navigateToRoot() {
        self.showRoot()
    }
    
    func navigateToOnboarding() {
        self.showOnboarding()
    }
}
