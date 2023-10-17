//
//  SplashBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 27.07.2021.
//

import Foundation
import UIKit
import Swinject

class SplashBuilder {
    static func build(injector: Container) -> SplashVC {
        let vc = SplashVC.board(name: .splash)
        let router = SplashRouter(injector: injector)
        router.viewController = vc
        let repository = SplashRepository(userNetworkProvider: injector.resolve(UserNetworkProvider.self)!)
        let viewModel = SplashViewModel(router: router, repository: repository)
        vc.viewModel = viewModel
        return vc
    }
}
