//
//  RecoveryVerificationRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 05.07.2021.
//

import Foundation

// MARK: - SignUpRouterRoutes
typealias RecoveryVerificationRoutes = SignInRoute & RootRoute

protocol RecoveryVerificationNavigation: RecoveryVerificationRoutes {
    func navigateToSignIn()
}

class RecoveryVerificationRouter: Router<RecoveryVerificationVC>, RecoveryVerificationNavigation {
    
    var rootTransition: Transition {
        return RootTransition(removeNavigation: true)
    }
    
    var signInTransition: Transition {
        return RootTransition()
    }
    
    func navigateToSignIn() {
        self.showSignIn()
    }
    
    func closeView() {
        self.openTransition = PushTransition()
        self.close()
    }
    
    func showProfile() {
        self.showRoot()
    }
}
