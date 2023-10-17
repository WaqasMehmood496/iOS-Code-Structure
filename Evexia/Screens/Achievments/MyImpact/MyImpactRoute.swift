//
//  MyImpactRoute.swift
//  Evexia
//
//  Created by admin on 16.02.2022.
//

import Foundation

// MARK: - MyImpactsRoute
protocol MyImpactsRoute {
    var impactTransition: Transition { get }
    
    func showImpact()
}
// MARK: - extension MyImpactsRoute
extension MyImpactsRoute where Self: RouterProtocol {
    func showImpact() {
        let vc = MyImpactBuilder.build(injector: injector)
        open(vc, transition: impactTransition)
    }
}
