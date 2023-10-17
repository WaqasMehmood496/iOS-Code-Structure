//
//  MyImpactRouter.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 15.02.2022.
//

import Foundation

// MARK: - MyImpactRouters
typealias MyImpactRouters = MyImpactsRoute

// MARK: - MyImpactNavigation
protocol MyImpactNavigation: MyImpactRouters {
    
}


// MARK: - MyImpactRouter
class MyImpactRouter: Router<MyImpactVC>, MyImpactNavigation {
    
    var impactTransition: Transition {
        return PushTransition()
    }
}
