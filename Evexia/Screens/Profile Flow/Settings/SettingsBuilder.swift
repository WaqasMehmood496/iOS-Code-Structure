//
//  SettingsBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 10.08.2021.
//

import Foundation
import Swinject

class SettingsBuilder {
    static func build(injector: Container) -> SettingsVC {
        let vc = SettingsVC.board(name: .settings)
        let router = SettingsRouter(injector: injector)
        router.viewController = vc
        let repository = SettingsRepository(userNetworkProvider: injector.resolve(UserNetworkProvider.self)!, biometricdService: injector.resolve(BiometricdService.self)!)
        
        let viewModel = SettingsVM(router: router, repository: repository)
        vc.viewModel = viewModel
        return vc
    }
}
