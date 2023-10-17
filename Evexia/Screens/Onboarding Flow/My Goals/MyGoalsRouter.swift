//
//  MyGoalsRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 19.07.2021.
//

import Foundation

// MARK: - MyWhyNavigation: MyWhyRoutes
protocol MyGoalsNavigation {
}

// MARK: - MyGoalsRouter
class MyGoalsRouter: Router<MyGoalsVC>, MyGoalsNavigation {
    
    var nextViewTrigger: (() -> Void)?
}
