//
//  RootRoute.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 30.06.2021.
//

import Foundation

protocol RootRoute {
    var rootTransition: Transition { get }
    
    func showRoot()
}

extension RootRoute where Self: RouterProtocol {
    func showRoot() {
        let vc = RootBuilder.build(injector: injector)
        open(vc, transition: rootTransition)
    }
}
