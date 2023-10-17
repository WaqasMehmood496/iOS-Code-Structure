//
//  VerificationRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 01.07.2021.
//

import Foundation

protocol VerificationRoute {
    var verificationTransition: Transition { get }
    
    func showVerification(for email: String)
}

extension VerificationRoute where Self: RouterProtocol {
    func showVerification(for email: String) {
        let vc = VerificationBuilder.build(injector: self.injector, email: email)
        open(vc, transition: verificationTransition)
    }
}
