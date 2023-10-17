//
//  AchievmentsBuilder.swift
//  Evexia
//
//  Created by Oleg Pogosian on 05.01.2022.
//

import Foundation
import UIKit
import Swinject

class AchievmentsBuilder {
    static func build(injector: Container, dailySteps: Int) -> UIViewController {
        let vc = AchievmentsVC.board(name: .achievments)
        let router = AchievmentsRouter(injector: injector)
        router.viewController = vc
        let repository = AchievmentsRepository(achievmentsNetworkProvider: injector.resolve(AchievmentsNetworkProvider.self)!)
        let viewModel = AchievmentsVM(repository: repository, router: router, dailySteps: dailySteps)
        vc.viewModel = viewModel
        return vc
    }
}
