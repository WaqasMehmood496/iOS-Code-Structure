//
//  DiaryBuilder.swift
//  Evexia
//
//  Created by admin on 07.09.2021.
//

import Foundation

final class DiaryBuilder {
    
    static func build(router: DiaryRouter) -> DiaryVC {
        let vc = DiaryVC.board(name: .diary)
        router.viewController = vc
        let repository = DiaryRepository(diaryNetworkProvider: router.injector.resolve(DiaryNetworkProvider.self)!)
        let viewModel = DiaryVM(router: router, repository: repository, healthStore: router.injector.resolve(HealthStore.self)!)
        vc.viewModel = viewModel
        return vc
    }
}
