//
//  VerificationBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 01.07.2021.
//

import Foundation
import UIKit
import Swinject

class VerificationBuilder {
    static func build(injector: Container, email: String) -> VerificationVC {
        let viewController = VerificationVC.board(name: .verification)
        let router = VerificationRouter(injector: injector)
        router.viewController = viewController
        let repository = VerificationRepository(authNetworkProvider: injector.resolve(UserNetworkProvider.self)!)

        let viewModel = VerificationVM(router: router, repository: repository, email: email)
        viewController.viewModel = viewModel
        return viewController
    }
}
