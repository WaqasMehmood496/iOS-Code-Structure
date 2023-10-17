//
//  QuestionnaireResultVM.swift
//  Evexia
//
//  Created by admin on 28.09.2021.
//

import Foundation

final class QuestionnaireResultVM {
    
    internal let result: WellbeingScore
    
    private let router: QuestionnaireResultNavigation

    init(router: QuestionnaireResultNavigation, result: WellbeingScore) {
        self.router = router
        self.result = result
    }
    
    // MARK: - Navigation
    internal func navigateToLibrary() {
        self.router.navigateToLibrary()
    }
    
    internal func navigateToDiary() {
        self.router.navigateToDiary()
    }
    
    internal func navigateToCustomerSupport() {
        self.router.showAdvise()
    }
    
    internal func closeView() {
        self.router.closeView()
    }
}
