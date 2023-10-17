//
//  PasswordRecoveryBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 02.07.2021.
//

import Foundation
import UIKit
import Swinject

class PasswordRecoveryBuilder {
    static func build(injector: Container) -> PasswordRecoveryVC {
        let viewController = PasswordRecoveryVC.board(name: .passwordRecovery)
        let router = PasswordRecoveryRouter(injector: injector)
        router.viewController = viewController
        let repository = PasswordRecoveryRepository(userNetworkProvider: injector.resolve( UserNetworkProvider.self)!)

        let viewModel = PasswordRecoveryVM(router: router, repository: repository)
        viewController.viewModel = viewModel

        return viewController
    }
}
