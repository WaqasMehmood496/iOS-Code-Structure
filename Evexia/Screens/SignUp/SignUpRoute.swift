//
//  SignUpRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.06.2021.
//

import Foundation

protocol SignUpRoute {
    var signUpTransition: Transition { get }
    
    func showSignUp()
}

extension SignUpRoute where Self: RouterProtocol {
    func showSignUp() {
        let vc = SignUpBuilder.build(injector: self.injector)
        open(vc, transition: signUpTransition)
    }
}
