//
//  BenefitsBuilder.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 20.08.2021.
//

import Swinject

final class BenefitsBuilder {
    
    static func build(injector: Container) -> BenefitsVC {
        let vc = BenefitsVC.board(name: .benefits)
        let router = BenefitsRouter(injector: injector)
        router.viewController = vc
        let repository: BenefitsRepositoryProtocol = BenefitsRepository(benefitsNetworkProvider: injector.resolve(BenefitsNetworkProvider.self)!)
        let viewModel: BenefitsVMType = BenefitsVM(repository: repository, router: router)
        vc.viewModel = viewModel
        return vc
    }
}
