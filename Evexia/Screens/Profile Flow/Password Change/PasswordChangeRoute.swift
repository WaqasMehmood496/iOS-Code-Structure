//
//  PasswordChangeRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 17.08.2021.
//

import Foundation

protocol PasswordChangeRoute {

    var passwordChangeTransition: Transition { get }
    
    func showPasswordChange()
}

extension PasswordChangeRoute where Self: RouterProtocol {
    func showPasswordChange() {
        let vc = PasswordChangeBuilder.build(injector: self.injector)
        open(vc, transition: passwordChangeTransition)
    }
}
