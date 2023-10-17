//
//  AgreementsVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 05.07.2021.
//

import Foundation
import Combine

class AgreementsVM {
    
    // MARK: - Properties
    internal var type: Agreements
    private var router: AgreementsRouter
    
    init(router: AgreementsRouter, type: Agreements) {
        self.router = router
        self.type = type
    }
}

// MARK: - AgreementsVM: AgreementsVMType
extension AgreementsVM: AgreementsVMType {
    func navigateToAgreements(type: Agreements) {
        self.router.navigateToAgreements(type: type)
    }
}
