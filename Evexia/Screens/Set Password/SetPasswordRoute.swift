//
//  SetPasswordRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 06.07.2021.
//

import Foundation

protocol SetPasswordRoute {
    var setPasswordTransition: Transition { get }
    
    func showSetPassword(token: String)
}

extension SetPasswordRoute where Self: RouterProtocol {
    func showSetPassword(token: String) {
        let vc = SetPasswordBuilder.build(injector: self.injector, token: token)
        open(vc, transition: self.setPasswordTransition)
    }
}
