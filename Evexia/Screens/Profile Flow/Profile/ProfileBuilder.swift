//
//  ProfileBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 18.08.2021.
//

import Foundation
import Swinject

class ProfileBuilder {
    static func build(injector: Container) -> ProfileVC {
        let vc = ProfileVC.board(name: .profile)
        let router = ProfileRouter(injector: injector)
        router.viewController = vc
        let repository = ProfileRepository(healthStore: injector.resolve(HealthStore.self)!, userNetworkProvider: injector.resolve(UserNetworkProvider.self)!, achievementsNetworkProvider: injector.resolve(AchievmentsNetworkProvider.self)!, biometricService: injector.resolve(BiometricdService.self)!)
        let viewModel = ProfileVM(router: router, repository: repository)
        vc.viewModel = viewModel
        return vc
    }
}
