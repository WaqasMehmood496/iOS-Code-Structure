//
//  MyAvailabilityRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.07.2021.
//

import Foundation

// MARK: - MyAvailabilityRoutes

typealias MyAvailabilityRoutes = RootRoute

// MARK: - MyWhyNavigation: MyWhyRoutes
protocol MyAvailabilityNavigation: MyAvailabilityRoutes {
    func closeView()
    func navigateToRoot()

    var nextViewTrigger: (() -> Void)? { get set }
}

// MARK: - MyAvailabilityRouter
class MyAvailabilityRouter: Router<MyAvailabilityVC>, MyAvailabilityNavigation {
    
    var rootTransition: Transition {
        return RootTransition(removeNavigation: true)
    }
    
    var nextViewTrigger: (() -> Void)?
    
    func closeView() {
        self.openTransition = PushTransition()
        self.close()
    }
    
    func navigateToRoot() {
        self.showRoot()
    }
}
