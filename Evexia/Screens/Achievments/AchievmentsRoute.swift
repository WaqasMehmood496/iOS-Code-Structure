//
//  AchievmentsRoute.swift
//  Evexia
//
//  Created by Oleg Pogosian on 05.01.2022.
//

import Foundation

protocol AchievmentsRoute {
    var pdTransition: Transition { get }
    
    func showAchievments(dailySteps: Int)
}

extension AchievmentsRoute where Self: RouterProtocol {
    func showAchievments(dailySteps: Int) {
        let vc = AchievmentsBuilder.build(injector: self.injector, dailySteps: dailySteps)
        open(vc, transition: pdTransition)
    }
}
