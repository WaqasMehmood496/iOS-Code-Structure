//
//  SetParameterRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.07.2021.
//

import Foundation

protocol SetParameterRoute {

    var setParameterTransition: Transition { get }
    
    func showSetParameter(model: ProfileCellModel)
}

extension SetParameterRoute where Self: RouterProtocol {
    func showSetParameter(model: ProfileCellModel) {
        let vc = SetParameterBuilder.build(injector: self.injector, model: model)
        open(vc, transition: setParameterTransition)
    }
}
