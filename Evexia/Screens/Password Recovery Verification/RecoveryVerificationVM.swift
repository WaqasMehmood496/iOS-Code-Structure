//
//  RecoveryVerificationVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 05.07.2021.
//

import Foundation
import Combine

enum ForgorPasswordFlow {
    case logged
    case notLogged
}

class RecoveryVerificationVM {
    
    // MARK: - Properties
    private var router: RecoveryVerificationRouter
    private let screenFlow: ForgorPasswordFlow

    init(router: RecoveryVerificationRouter, screenFlow: ForgorPasswordFlow) {
        self.router = router
        self.screenFlow = screenFlow
    }
}

// MARK: - RecoveryVerificationVM: RecoveryVerificationVMType
extension RecoveryVerificationVM: RecoveryVerificationVMType {
    
    // - Navigation
    func navigateToSignUp() {
        switch self.screenFlow {
        case .logged:
            self.router.showProfile()
        case .notLogged:
            self.router.navigateToSignIn()
        }
    }
}
