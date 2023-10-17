//
//  MeasurementSystemBuilder.swift
//  Evexia
//
//  Created by Александр Ковалев on 15.11.2022.
//

import Foundation
import Swinject

class MeasurementSystemBuilder {
    static func build(injector: Container) -> MeasurementSystemVC {
        let vc = MeasurementSystemVC.board(name: .measurementSystem)
        let viewModel = MeasurementSystemVM()
        
        vc.viewModel = viewModel
        
        return vc
    }
}
