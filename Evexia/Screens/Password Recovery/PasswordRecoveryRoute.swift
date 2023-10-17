//
//  PasswordRecoveryRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 02.07.2021.
//

import Foundation

protocol PasswordRecoveryRoute {
    var passwordRecoveryTransition: Transition { get }
    
    func showPasswordRecovery()
}

extension PasswordRecoveryRoute where Self: RouterProtocol {
    func showPasswordRecovery() {
        let vc = PasswordRecoveryBuilder.build(injector: self.injector)
        open(vc, transition: self.passwordRecoveryTransition)
    }
}
