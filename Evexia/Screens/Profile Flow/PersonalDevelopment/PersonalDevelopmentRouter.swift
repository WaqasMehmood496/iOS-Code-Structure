//
//  PersonalDevelopmentRouter.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 07.12.2021.
//

import Foundation
import UIKit

typealias PersonalDevelopmentRoutes = PDCategoryDetailsRoute

class PersonalDevelopmentRouter: Router<PersonalDevelopmentVC>, PersonalDevelopmentRoutes {
    
    var pdTransition: Transition {
        return PushTransition()
    }
    
    func showPersonalDevelopmentCategory(id: Int, title: String) {
        self.showPersonalDevelopmentCategory(id: id, title: title)
    }
    
}
