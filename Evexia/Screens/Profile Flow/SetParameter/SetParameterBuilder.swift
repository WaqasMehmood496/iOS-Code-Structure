//
//  SetParameterBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.07.2021.
//

import Foundation
import Swinject
import UIKit

final class SetParameterBuilder {
    
    static func build(injector: Container, model: ProfileCellModel) -> SetParameterVC {
        let vc = SetParameterVC.board(name: .setParameter)
        let router = SetParameterRouter(injector: injector)
        router.viewController = vc
        let repository = SetParameterRepository(userNetworkProvider: injector.resolve(UserNetworkProvider.self)!)
        let viewModel = SetParameterVM(router: router, repository: repository, model: model)
        vc.viewModel = viewModel
       
        return vc
    }
}
