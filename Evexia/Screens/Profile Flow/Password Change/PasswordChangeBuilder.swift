//
//  PasswordChangeBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 16.08.2021.
//

import Foundation
import Swinject

final class PasswordChangeBuilder {
    static func build(injector: Container) -> PasswordChangeVC {
        let vc = PasswordChangeVC.board(name: .passwordChange)
        let router = PasswordChangeRouter(injector: injector)
        router.viewController = vc
        let repository = PasswordChangeRepository(userNetworkProvider: injector.resolve(UserNetworkProvider.self)!)
        let vm = PasswordChangeVM(router: router, repository: repository)
        vc.viewModel = vm
        return vc
    }
}
