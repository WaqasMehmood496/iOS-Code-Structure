//
//  RecoveryVerificationBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 05.07.2021.
//

import Foundation
import UIKit
import Swinject

class RecoveryVerificationBuilder {
    static func build(injector: Container) -> RecoveryVerificationVC {
        let viewController = RecoveryVerificationVC.board(name: .recoveryVerification)
        let router = RecoveryVerificationRouter(injector: injector)
        router.viewController = viewController

        let flow: ForgorPasswordFlow = UserDefaults.userModel != nil ? .logged : .notLogged
        
        let viewModel = RecoveryVerificationVM(router: router, screenFlow: flow)
        viewController.viewModel = viewModel

        return viewController
    }
}
