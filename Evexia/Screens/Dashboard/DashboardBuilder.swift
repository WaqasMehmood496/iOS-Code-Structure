//
//  DashboardBuilder.swift
//  Evexia
//
//  Created by admin on 11.09.2021.
//

import Foundation
import UIKit
import Swinject

class DashboardBuilder {
    static func build(injector: Container) -> UIViewController {
        let vc = DashboardVC.board(name: .dashboard)
        let router = DashboardRouter(injector: injector)
        router.viewController = vc
        let repository = DashboardRepository(dashboardNetworkProvider: injector.resolve(DashboardNetworkProvider.self)!, healthStore: injector.resolve(HealthStore.self)!, questionnaireNetworkProvider: injector.resolve(QuestionnaireNetworkProvider.self)!)
        let viewModel = DashboardVM(router: router, repository: repository)
        vc.viewModel = viewModel
        return vc
    }
}
