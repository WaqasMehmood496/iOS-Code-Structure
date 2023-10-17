//
//  AgreementsBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 05.07.2021.
//

import Foundation
import UIKit
import Swinject

class AgreementsBuilder {
    static func build(injector: Container, type: Agreements) -> AgreementsVC {
        let viewController = AgreementsVC.board(name: .agreements)
        let router = AgreementsRouter(injector: injector)
        router.viewController = viewController

        let viewModel = AgreementsVM(router: router, type: type)
        viewController.viewModel = viewModel

        return viewController
    }
}
