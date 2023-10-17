//
//  SignInRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 24.06.2021.
//

import Foundation

protocol SignInRoute {
    var signInTransition: Transition { get }
    
    func showSignIn()
}

extension SignInRoute where Self: RouterProtocol {
    func showSignIn() {
        let vc = SignInBuilder.build(injector: injector)
        open(vc, transition: signInTransition)
    }
}
