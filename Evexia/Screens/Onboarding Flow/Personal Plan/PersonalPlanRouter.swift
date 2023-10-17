//
//  PersonalPlanRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import Foundation

protocol PersonalPlanNavigation {
    var nextViewTrigger: (() -> Void)? { get }
}

class PersonalPlanRouter: Router<PersonalPlanVC>, PersonalPlanNavigation {
    
    var nextViewTrigger: (() -> Void)?
}
