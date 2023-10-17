//
//  PasswordChangeRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 17.08.2021.
//

import Foundation

typealias PasswordChangeRoutes = PasswordRecoveryRoute

protocol PasswordChangeNavigation: PasswordChangeRoutes {
    func navigateToSetPassword()
    func closeView()
}

class PasswordChangeRouter: Router<PasswordChangeVC>, PasswordChangeNavigation {
    
    var passwordRecoveryTransition: Transition {
        return PushTransition()
    }
    
    func navigateToSetPassword() {
        self.showPasswordRecovery()
    }
    
    func closeView() {
        self.openTransition = PushTransition()
        self.close()
    }
}
