//
//  SetPusswordBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 06.07.2021.
//

import Foundation
import UIKit
import Swinject

class SetPasswordBuilder {
    static func build(injector: Container, token: String) -> SetPasswordVC {
        let viewController = SetPasswordVC.board(name: .setPassword)
        let router = SetPasswordRouter(injector: injector)
        router.viewController = viewController

        let repository = SetPasswordRepository(userNetworkProvider: injector.resolve(UserNetworkProvider.self)!, token: token)
        
        let viewModel = SetPasswordVM(router: router, repository: repository)
        viewController.viewModel = viewModel

        return viewController
    }
}
