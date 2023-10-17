//
//  MeasurementSystemRoute.swift
//  Evexia
//
//  Created by Александр Ковалев on 15.11.2022.
//

import Foundation

protocol MeasurementSystemRoute {
    
    var measurementSystemTransition: Transition { get }
    
    func showMeasurementSystem()
}

extension MeasurementSystemRoute where Self: RouterProtocol {
    func showMeasurementSystem() {
        let vc = MeasurementSystemBuilder.build(injector: self.injector)
        open(vc, transition: measurementSystemTransition)
    }
}
