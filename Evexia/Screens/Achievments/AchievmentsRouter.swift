//
//  AchievmentsRouter.swift
//  Evexia
//
//  Created by Oleg Pogosian on 05.01.2022.
//

import Foundation
import UIKit

typealias AchievmentsRoutes = AchievmentsRoute & MyImpactsRoute

protocol AchievmentsNavigation: AchievmentsRoutes {
    func navigationToImpact()
}

class AchievmentsRouter: Router<AchievmentsVC>, AchievmentsNavigation {
    
    var impactTransition: Transition {
        return PushTransition()
    }
    
    var pdTransition: Transition {
        return PushTransition()
    }
    
    func navigationToImpact() {
        showImpact()
    }
}
