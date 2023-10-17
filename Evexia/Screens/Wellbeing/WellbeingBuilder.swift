//
//  WellbeingBuilder.swift
//  Evexia Staging
//
//  Created by Roman Korostenskyi on 26.08.2021.
//

import Swinject

final class WellbeingBuilder {
    
    static func build(injector: Container, statisticType: StatisticType) -> WellbeingVC {
        let vc = WellbeingVC.board(name: .wellbeing)
        let repository: WellbeingRepositoryProtocol = WellbeingRepository(networkProvider: injector.resolve(WellbeingNetworkProvider.self)!, healthStore: injector.resolve(HealthStore.self)!, statisticType: statisticType)
        let router = WellbeingRouter(injector: injector)
        router.viewController = vc
        let viewModel = WellbeingVM(router: router, repository: repository, statisticType: statisticType)
        vc.viewModel = viewModel
        return vc
    }
}
