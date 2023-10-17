//
//  AdviseRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 27.08.2021.
//

import Foundation

protocol AdviseRoute {

    var adviseTransition: Transition { get }
    
    func showAdvise()
}

extension AdviseRoute where Self: RouterProtocol {
    func showAdvise() {
        let vc = AdviseBuilder.build(injector: self.injector)
        open(vc, transition: adviseTransition)
    }
}
