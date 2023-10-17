//
//  SignUpBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.06.2021.
//

import UIKit
import Swinject

class SignUpBuilder {
    static func build(injector: Container) -> SignUpVC {
        let viewController = SignUpVC.board(name: .signUp)
        let router = SignUpRouter(injector: injector)
        router.viewController = viewController
        let repository = SignUpRepository(authNetworkProvider: injector.resolve(UserNetworkProvider.self)!)

        let viewModel = SignUpVM(router: router, repository: repository)
        viewController.viewModel = viewModel
        
        return viewController
    }
}
