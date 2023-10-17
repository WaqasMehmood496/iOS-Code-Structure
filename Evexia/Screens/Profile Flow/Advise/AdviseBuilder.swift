//
//  AdviseBuilder.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 17.08.2021.
//

import Foundation
import Swinject

final class AdviseBuilder {
    
    static func build(injector: Container) -> AdviseVC {
        let vc = AdviseVC.board(name: .advise)
        let router = AdviseRouter(injector: injector)
        router.viewController = vc
        let repository = AdviseRepository(benefitsNetworkProvider: injector.resolve(BenefitsNetworkProvider.self)!)
        let viewModel = AdviseVM(repository: repository, router: router)
        vc.viewModel = viewModel
        return vc
    }
}
