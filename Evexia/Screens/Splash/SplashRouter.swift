//
//  SplashRouter.swift
//  Evexia
//
//  Created by admin on 02.05.2022.
//

import Foundation

// MARK: - SplashRouterRoutes
typealias SplashRoutes = OnboardingRootRoute & RootRoute & SignInRoute & VerificationRoute & OnboardingRoute

protocol SplashNavigation: SplashRoutes {
    
}

class SplashRouter: Router<SplashVC>, SplashNavigation {
    var onboardingTransition: Transition {
        return RootTransition()
    }
    var changeOnboardingRooTransition: Transition {
        return RootTransition()
    }
    
    var signInTransition: Transition {
        return RootTransition()
    }
    
    var verificationTransition: Transition {
        return RootTransition()
    }
    
    var onboardingRootTransition: Transition {
        return RootTransition()
    }
    
    var rootTransition: Transition {
        return RootTransition(removeNavigation: true)
    }
    
    func navigateToOnboarding(){
        showOnboarding()
    }
}
