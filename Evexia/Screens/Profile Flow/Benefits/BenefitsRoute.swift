//
//  BenefitsRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 27.08.2021.
//

import Foundation

protocol BenefitsRoute {

    var benefitsTransition: Transition { get }
    
    func showBenefits()
}

extension BenefitsRoute where Self: RouterProtocol {
    func showBenefits() {
        let vc = BenefitsBuilder.build(injector: self.injector)
        open(vc, transition: benefitsTransition)
    }
}
