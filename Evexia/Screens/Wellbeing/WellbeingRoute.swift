//
//  WellbeingRoute.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 01.09.2021.
//

import Foundation
protocol WellbeingRoute {

    var wellbeingTransition: Transition { get }
    
    func showWellbeing(statisticType: StatisticType)
}

extension WellbeingRoute where Self: RouterProtocol {
    func showWellbeing(statisticType: StatisticType) {
        let vc = WellbeingBuilder.build(injector: self.injector, statisticType: statisticType)
        open(vc, transition: wellbeingTransition)
    }
}
