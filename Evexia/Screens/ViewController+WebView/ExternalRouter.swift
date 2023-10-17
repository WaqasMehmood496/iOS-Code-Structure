//
//  ExternalRouter.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 01.09.2021.
//

import Foundation

typealias ExternalRoutes = OnboardingRoute & RootRoute & SignInRoute

protocol ExternalNavigation: ExternalRoutes { }

class ExternalRouter: Router<ExternalVC>, ExternalNavigation {
    
    var signInTransition: Transition {
        return RootTransition()
    }
        
    var rootTransition: Transition {
        return RootTransition(removeNavigation: true)
    }
    
    var onboardingTransition: Transition {
        return ReplacingPushTransition()
    }
}
