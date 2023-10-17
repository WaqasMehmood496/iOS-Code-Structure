//
//  PasswordRecoveryRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 02.07.2021.
//

import Foundation

// MARK: - SignUpRouterRoutes
typealias PasswordRecoveryRoutes = RecoveryVerificationRoute

protocol PasswordRecoveryNavigation: PasswordRecoveryRoutes {
    func navigateToRecoveryVerification()
}

class PasswordRecoveryRouter: Router<PasswordRecoveryVC>, PasswordRecoveryNavigation {
    
    var recoveryVerificationTransition: Transition {
        return PushTransition()
    }
    
    func navigateToRecoveryVerification() {
        self.showRecoveryVerification()
    }
}
