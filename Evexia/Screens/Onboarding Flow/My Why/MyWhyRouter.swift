//
//  MyWhyRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import Foundation

// MARK: - MyWhyRouterRoutes
typealias MyWhyRoutes = MyGoalsRoute

// MARK: - MyWhyNavigation: MyWhyRoutes
protocol MyWhyNavigation: MyWhyRoutes {

}

// MARK: - MyWhyRouter
class MyWhyRouter: Router<MyWhyVC>, MyWhyRoutes {
    
    var nextViewTrigger: (() -> Void)?
}
