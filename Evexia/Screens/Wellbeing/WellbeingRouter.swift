//
//  WellbeingRouter.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 02.09.2021.
//

import Foundation

typealias WellbeingRoutes = SetParameterRoute

protocol WellbeingNavigation: WellbeingRoutes {
   func navigateToSeWeight(model: ProfileCellModel)
}

class WellbeingRouter: Router<WellbeingVC>, WellbeingNavigation {
    var setParameterTransition: Transition {
        return PushTransition()
    }
    
    func navigateToSeWeight(model: ProfileCellModel) {
        self.showSetParameter(model: model)
    }
}
