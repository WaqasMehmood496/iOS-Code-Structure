//
//  SingnInBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 24.06.2021.
//

import Foundation
import Swinject
import UIKit

final class SignInBuilder {
    static func build(injector: Container) -> SignInVC {
        let viewController = SignInVC.board(name: .signIn)
        let router = SignInRouter(injector: injector)
        router.viewController = viewController
        let repository = SignInRepository(userNetworkProvider: injector.resolve(UserNetworkProvider.self)!)

        let signInVM = SignInVM(router: router, repository: repository)
        viewController.viewModel = signInVM
        return viewController
    }
}
