//
//  PersonalDevelopmentRoute.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 08.12.2021.
//

import Foundation

protocol PersonalDevelopmentRoute {

    var pdTransition: Transition { get }
    
    func showPersonalDevelopment()
}

extension PersonalDevelopmentRoute where Self: RouterProtocol {
    func showPersonalDevelopment() {
        let vc = PersonalDevelopmentBuilder.build(injector: self.injector)
        open(vc, transition: pdTransition)
    }
}
