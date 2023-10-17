//
//  PersonalDevelopmentBuilder.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 07.12.2021.
//

import Foundation
import Swinject

final class PersonalDevelopmentBuilder {
    
    static func build(injector: Container) -> PersonalDevelopmentVC {
        let vc = PersonalDevelopmentVC.board(name: .personalDevelopment)
        let router = PersonalDevelopmentRouter(injector: injector)
        router.viewController = vc
        let repository = PersonalDevelopmentRepository(pdNetworkProvider: injector.resolve(PersonalDevelopmentNetworkProvider.self)!)
        let viewModel = PersonalDevelopmentVM(repository: repository, router: router)
        vc.viewModel = viewModel
        return vc
    }
}
