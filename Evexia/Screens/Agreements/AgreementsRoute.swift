//
//  AgreementsRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 05.07.2021.
//

import Foundation

protocol AgreementsRoute {
    var agreementsTransition: Transition { get }
    
    func showAgreements(type: Agreements)
}

extension AgreementsRoute where Self: RouterProtocol {
    func showAgreements(type: Agreements) {
        let vc = AgreementsBuilder.build(injector: self.injector, type: type)
        open(vc, transition: self.agreementsTransition)
    }
}
