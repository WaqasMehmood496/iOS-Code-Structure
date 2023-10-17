//
//  AgreementsRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 05.07.2021.
//

import Foundation

// MARK: - AgreementsRoutes
 typealias AgreementsRoutes = AgreementsRoute

protocol AgreementsNavigation: AgreementsRoutes {
    func navigateToAgreements(type: Agreements)
}

class AgreementsRouter: Router<AgreementsVC>, AgreementsNavigation {
    var agreementsTransition: Transition {
        return ReplacingPushTransition()
    }
    
    func navigateToAgreements(type: Agreements) {
        self.showAgreements(type: type)
    }
}
