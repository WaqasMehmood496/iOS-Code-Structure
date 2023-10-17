//
//  RecoveryVerificationRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 05.07.2021.
//

import Foundation

protocol RecoveryVerificationRoute {
    var recoveryVerificationTransition: Transition { get }
    
    func showRecoveryVerification()
}

extension RecoveryVerificationRoute where Self: RouterProtocol {
    func showRecoveryVerification() {
        let vc = RecoveryVerificationBuilder.build(injector: self.injector)
        open(vc, transition: self.recoveryVerificationTransition)
    }
}
